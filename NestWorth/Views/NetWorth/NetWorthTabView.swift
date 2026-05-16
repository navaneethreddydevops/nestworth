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
    private var netWorth:         Double { totalAssets - totalLiabilities }
    private var previousNetWorth: Double? { snapshots.first?.netWorth }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.sectionSpacing) {
                header
                allocationCard
                topHoldingsCard
                holdingsSection(
                    title: "Assets", count: assets.count,
                    emptyIcon: "building.columns", emptyTitle: "No Assets",
                    emptySubtitle: "Add bank accounts, investments, or property",
                    onAdd: { showAddAsset = true }
                ) {
                    ForEach(assets) { asset in
                        let idx = AssetType.allCases.firstIndex(of: asset.type) ?? 0
                        let color = AppTheme.assetColors[safe: idx] ?? AppTheme.mint
                        HoldingRow(name: asset.name, detail: asset.type.rawValue,
                                   amount: asset.value, icon: asset.type.icon,
                                   iconColor: color, amountColor: AppTheme.mint)
                        .contentShape(Rectangle())
                        .onTapGesture { editingAsset = asset }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) { modelContext.delete(asset) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        if asset.id != assets.last?.id {
                            Divider().background(AppTheme.hairline).padding(.leading, 62)
                        }
                    }
                }
                holdingsSection(
                    title: "Liabilities", count: liabilities.count,
                    emptyIcon: "creditcard", emptyTitle: "No Liabilities",
                    emptySubtitle: "Add credit cards, loans, or mortgage",
                    onAdd: { showAddLiability = true }
                ) {
                    ForEach(liabilities) { liability in
                        HoldingRow(name: liability.name, detail: liability.type.rawValue,
                                   amount: liability.balance, icon: liability.type.icon,
                                   iconColor: liability.type.color, amountColor: AppTheme.coral)
                        .contentShape(Rectangle())
                        .onTapGesture { editingLiability = liability }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) { modelContext.delete(liability) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        if liability.id != liabilities.last?.id {
                            Divider().background(AppTheme.hairline).padding(.leading, 62)
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.cardPadding)
            .padding(.top, 56)
        }
        .background(appBackground)
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 90) }
        .sheet(isPresented: $showAddAsset)      { AddAssetSheet() }
        .sheet(isPresented: $showAddLiability)  { AddLiabilitySheet() }
        .sheet(item: $editingAsset)     { AddAssetSheet(existing: $0) }
        .sheet(item: $editingLiability) { AddLiabilitySheet(existing: $0) }
        .onChange(of: netWorth) { _, _ in autoSaveSnapshot() }
    }

    // Auto-save or update today's snapshot whenever net worth changes
    private func autoSaveSnapshot() {
        let descriptor = FetchDescriptor<NetWorthSnapshot>()
        guard let all = try? modelContext.fetch(descriptor) else { return }
        let today = Calendar.current.startOfDay(for: Date())
        if let existing = all.first(where: { Calendar.current.isDate($0.snapshotDate, inSameDayAs: today) }) {
            existing.totalAssets      = totalAssets
            existing.totalLiabilities = totalLiabilities
        } else {
            let snap = NetWorthSnapshot(
                displayMonth:     DateHelpers.currentMonth(),
                displayYear:      DateHelpers.currentYear(),
                totalAssets:      totalAssets,
                totalLiabilities: totalLiabilities,
                note:             ""
            )
            modelContext.insert(snap)
        }
    }

    private var appBackground: some View {
        ZStack {
            AppTheme.background
            RadialGradient(colors: [AppTheme.mint.opacity(0.06), .clear], center: .top, startRadius: 0, endRadius: 300)
        }.ignoresSafeArea()
    }

    // MARK: - Header
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("NET WORTH")
                    .font(.system(size: 11, weight: .heavy)).tracking(11 * 0.08)
                    .foregroundStyle(AppTheme.textTertiary)
                Text(CurrencyFormatter.format(netWorth))
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.textPrimary)
                    .contentTransition(.numericText(value: netWorth))
                    .animation(.spring(duration: 0.4), value: netWorth)
            }
            Spacer()
            if let prev = previousNetWorth {
                DeltaChip(delta: netWorth - prev)
                    .padding(.top, 22)
            }
        }
    }

    // MARK: - Asset allocation donut
    private var allocationCard: some View {
        GlassCard("Asset Allocation") {
            AssetAllocationChart(assets: assets)
        }
    }

    // MARK: - Top holdings proportional bar + ranked list
    private var topHoldingsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("TOP HOLDINGS")
                    .font(.system(size: 12, weight: .heavy)).tracking(12 * 0.08)
                    .foregroundStyle(AppTheme.textTertiary)
                Spacer()
                Text("by value").font(.system(size: 11)).foregroundStyle(AppTheme.textTertiary)
            }

            if assets.isEmpty {
                EmptyStateView(systemImage: "chart.bar", title: "No Assets", subtitle: "Add assets to see your holdings breakdown")
            } else {
                let sorted = assets.sorted { $0.value > $1.value }
                let total  = max(totalAssets, 1)

                // Proportional multi-color bar
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        ForEach(Array(sorted.enumerated()), id: \.offset) { i, asset in
                            let color = AppTheme.assetColors[i % AppTheme.assetColors.count]
                            RoundedRectangle(cornerRadius: 2)
                                .fill(color)
                                .frame(width: max(0, geo.size.width * CGFloat(asset.value / total) - 2))
                        }
                    }
                }
                .frame(height: 8)
                .clipShape(Capsule())

                // Ranked list (top 5)
                VStack(spacing: 11) {
                    ForEach(Array(sorted.prefix(5).enumerated()), id: \.offset) { i, asset in
                        let color = AppTheme.assetColors[i % AppTheme.assetColors.count]
                        HStack(spacing: 10) {
                            Text(String(format: "%02d", i + 1))
                                .font(.system(size: 11, weight: .semibold)).monospacedDigit()
                                .foregroundStyle(AppTheme.textQuaternary)
                                .frame(width: 18)
                            Circle().fill(color).frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(asset.name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .lineLimit(1)
                                Text(asset.type.rawValue)
                                    .font(.system(size: 10))
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 1) {
                                Text(CurrencyFormatter.formatCompact(asset.value))
                                    .font(.system(size: 13, weight: .bold)).monospacedDigit()
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text(String(format: "%.1f%%", asset.value / total * 100))
                                    .font(.system(size: 10)).monospacedDigit()
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                        }
                    }
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .darkCard()
    }

    // MARK: - Holdings section
    @ViewBuilder
    private func holdingsSection<Rows: View>(
        title: String, count: Int,
        emptyIcon: String, emptyTitle: String, emptySubtitle: String,
        onAdd: @escaping () -> Void,
        @ViewBuilder rows: () -> Rows
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(title.uppercased()) · \(count)")
                    .font(.system(size: 12, weight: .heavy)).tracking(12 * 0.08)
                    .foregroundStyle(AppTheme.textTertiary)
                Spacer()
                Button(action: onAdd) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus").font(.system(size: 12, weight: .bold))
                        Text("Add")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.mint)
                }
            }

            VStack(spacing: 0) {
                if count == 0 {
                    EmptyStateView(systemImage: emptyIcon, title: emptyTitle, subtitle: emptySubtitle)
                        .padding(AppTheme.cardPadding)
                } else {
                    rows()
                }
            }
            .darkCard()
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
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            Spacer()
            AnimatedCurrencyText(amount: amount, font: .system(size: 14, weight: .bold), color: amountColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
