import SwiftUI
import SwiftData

struct NetWorthTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var assets:      [Asset]
    @Query(sort: \NetWorthSnapshot.snapshotDate, order: .reverse)
    private var snapshots: [NetWorthSnapshot]
    @Query private var liabilities: [Liability]

    @State private var showAddAsset      = false
    @State private var showAddLiability  = false
    @State private var editingAsset:     Asset?     = nil
    @State private var editingLiability: Liability? = nil

    private var totalAssets:      Double { assets.reduce(0)      { $0 + $1.value } }
    private var totalLiabilities: Double { liabilities.reduce(0) { $0 + $1.balance } }
    private var previousNetWorth: Double? { snapshots.first?.netWorth }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.sectionSpacing) {

                    NetWorthSummaryCard(
                        totalAssets:      totalAssets,
                        totalLiabilities: totalLiabilities,
                        previousNetWorth: previousNetWorth
                    )

                    GlassCard("Asset Allocation") {
                        AssetAllocationChart(assets: assets)
                    }

                    holdingsSection(
                        title: "Assets",
                        isEmpty: assets.isEmpty,
                        emptyIcon: "building.columns",
                        emptyTitle: "No Assets",
                        emptySubtitle: "Add bank accounts, investments, or property",
                        onAdd: { showAddAsset = true }
                    ) {
                        ForEach(assets) { asset in
                            let idx = AssetType.allCases.firstIndex(of: asset.type) ?? 0
                            HoldingRow(
                                name: asset.name,
                                detail: asset.type.rawValue,
                                amount: asset.value,
                                icon: asset.type.icon,
                                iconColor: AppTheme.assetColors[safe: idx] ?? AppTheme.accent,
                                amountColor: AppTheme.income
                            )
                            .contentShape(Rectangle())
                            .onTapGesture { editingAsset = asset }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) { modelContext.delete(asset) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            if asset.id != assets.last?.id {
                                Divider().padding(.leading, 60)
                            }
                        }
                    }

                    holdingsSection(
                        title: "Liabilities",
                        isEmpty: liabilities.isEmpty,
                        emptyIcon: "creditcard",
                        emptyTitle: "No Liabilities",
                        emptySubtitle: "Add credit cards, loans, or mortgage",
                        onAdd: { showAddLiability = true }
                    ) {
                        ForEach(liabilities) { liability in
                            HoldingRow(
                                name: liability.name,
                                detail: liability.type.rawValue,
                                amount: liability.balance,
                                icon: liability.type.icon,
                                iconColor: AppTheme.expense,
                                amountColor: AppTheme.expense
                            )
                            .contentShape(Rectangle())
                            .onTapGesture { editingLiability = liability }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) { modelContext.delete(liability) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            if liability.id != liabilities.last?.id {
                                Divider().padding(.leading, 60)
                            }
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, AppTheme.cardPadding)
                .padding(.top, 8)
            }
            .background(AppTheme.background)
            .navigationTitle("Net Worth")
            .navigationBarTitleDisplayMode(.large)
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
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showAddAsset)      { AddAssetSheet() }
            .sheet(isPresented: $showAddLiability)  { AddLiabilitySheet() }
            .sheet(item: $editingAsset)     { AddAssetSheet(existing: $0) }
            .sheet(item: $editingLiability) { AddLiabilitySheet(existing: $0) }
        }
    }

    @ViewBuilder
    private func holdingsSection<Rows: View>(
        title: String,
        isEmpty: Bool,
        emptyIcon: String,
        emptyTitle: String,
        emptySubtitle: String,
        onAdd: @escaping () -> Void,
        @ViewBuilder rows: () -> Rows
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppTheme.accent)
                        .font(.title3)
                }
            }
            .padding(.horizontal, 2)

            GlassCard {
                if isEmpty {
                    EmptyStateView(
                        systemImage: emptyIcon,
                        title: emptyTitle,
                        subtitle: emptySubtitle
                    )
                } else {
                    VStack(spacing: 0) {
                        rows()
                    }
                }
            }
        }
    }
}

private struct HoldingRow: View {
    let name: String
    let detail: String
    let amount: Double
    let icon: String
    let iconColor: Color
    let amountColor: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            AnimatedCurrencyText(amount: amount, font: .subheadline.weight(.semibold), color: amountColor)
        }
        .padding(.vertical, 10)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
