import SwiftUI
import SwiftData

struct NetWorthTabView: View {
    @Query private var assets: [Asset]
    @Query private var liabilities: [Liability]

    @State private var showAddAsset = false
    @State private var showAddLiability = false
    @State private var editingAsset: Asset? = nil
    @State private var editingLiability: Liability? = nil

    @Environment(\.modelContext) private var modelContext

    private var totalAssets: Double { assets.reduce(0) { $0 + $1.value } }
    private var totalLiabilities: Double { liabilities.reduce(0) { $0 + $1.balance } }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NetWorthSummaryCard(totalAssets: totalAssets, totalLiabilities: totalLiabilities)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section {
                    if assets.isEmpty {
                        EmptyStateView(
                            systemImage: "building.columns",
                            title: "No Assets",
                            subtitle: "Add bank accounts, investments, or property",
                            actionLabel: "Add Asset"
                        ) { showAddAsset = true }
                    } else {
                        ForEach(assets) { asset in
                            NetWorthRow(
                                name: asset.name,
                                detail: asset.type.rawValue,
                                amount: asset.value,
                                icon: asset.type.icon,
                                iconColor: .green,
                                amountColor: .green
                            )
                            .contentShape(Rectangle())
                            .onTapGesture { editingAsset = asset }
                        }
                        .onDelete(perform: deleteAsset)
                    }
                } header: {
                    HStack {
                        Text("Assets")
                        Spacer()
                        Button { showAddAsset = true } label: {
                            Image(systemName: "plus.circle.fill").foregroundStyle(.blue)
                        }
                    }
                }

                Section {
                    if liabilities.isEmpty {
                        EmptyStateView(
                            systemImage: "creditcard",
                            title: "No Liabilities",
                            subtitle: "Add credit cards, loans, or mortgage",
                            actionLabel: "Add Liability"
                        ) { showAddLiability = true }
                    } else {
                        ForEach(liabilities) { liability in
                            NetWorthRow(
                                name: liability.name,
                                detail: liability.type.rawValue,
                                amount: liability.balance,
                                icon: liability.type.icon,
                                iconColor: .red,
                                amountColor: .red
                            )
                            .contentShape(Rectangle())
                            .onTapGesture { editingLiability = liability }
                        }
                        .onDelete(perform: deleteLiability)
                    }
                } header: {
                    HStack {
                        Text("Liabilities")
                        Spacer()
                        Button { showAddLiability = true } label: {
                            Image(systemName: "plus.circle.fill").foregroundStyle(.blue)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Net Worth")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showAddAsset = true } label: {
                            Label("Add Asset", systemImage: "building.columns")
                        }
                        Button { showAddLiability = true } label: {
                            Label("Add Liability", systemImage: "creditcard")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddAsset) {
                AddAssetSheet()
            }
            .sheet(isPresented: $showAddLiability) {
                AddLiabilitySheet()
            }
            .sheet(item: $editingAsset) { asset in
                AddAssetSheet(existing: asset)
            }
            .sheet(item: $editingLiability) { liability in
                AddLiabilitySheet(existing: liability)
            }
        }
    }

    private func deleteAsset(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(assets[index]) }
    }

    private func deleteLiability(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(liabilities[index]) }
    }
}

private struct NetWorthRow: View {
    let name: String
    let detail: String
    let amount: Double
    let icon: String
    let iconColor: Color
    let amountColor: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(CurrencyFormatter.format(amount))
                .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                .foregroundStyle(amountColor)
        }
        .padding(.vertical, 2)
    }
}
