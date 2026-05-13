import SwiftUI
import SwiftData

struct HistoryTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NetWorthSnapshot.snapshotDate, order: .reverse)
    private var snapshots: [NetWorthSnapshot]
    @Query private var assets:      [Asset]
    @Query private var liabilities: [Liability]

    @State private var showNotePrompt = false
    @State private var pendingNote    = ""
    @State private var selectedRange  = 3  // index into ranges

    private let ranges = ["1M", "3M", "6M", "1Y", "ALL"]

    private var totalAssets:      Double { assets.reduce(0)      { $0 + $1.value } }
    private var totalLiabilities: Double { liabilities.reduce(0) { $0 + $1.balance } }

    private var sorted: [NetWorthSnapshot] { snapshots.sorted { $0.snapshotDate < $1.snapshotDate } }

    private var latestNetWorth: Double { sorted.last?.netWorth ?? 0 }
    private var firstNetWorth:  Double { sorted.first?.netWorth ?? 0 }
    private var yoyGain:        Double { latestNetWorth - firstNetWorth }
    private var yoyPct:         Double { firstNetWorth != 0 ? yoyGain / abs(firstNetWorth) : 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.sectionSpacing) {
                header
                chartCard
                snapshotButton
                if !snapshots.isEmpty { statsGrid }
                timeline
            }
            .padding(.horizontal, AppTheme.cardPadding)
            .padding(.top, 56)
        }
        .background(appBackground)
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 90) }
        .alert("Add a Note", isPresented: $showNotePrompt) {
            TextField("Optional note...", text: $pendingNote)
            Button("Save", action: saveSnapshot)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Optionally describe what changed this month.")
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
        VStack(alignment: .leading, spacing: 2) {
            Text("HISTORY")
                .font(.system(size: 11, weight: .heavy)).tracking(11 * 0.08)
                .foregroundStyle(AppTheme.textTertiary)
            Text("Last 12 months")
                .font(.system(size: 28, weight: .bold)).tracking(-0.02 * 28)
                .foregroundStyle(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Chart card
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NET WORTH")
                        .font(.system(size: 11, weight: .heavy)).tracking(11 * 0.08)
                        .foregroundStyle(AppTheme.textTertiary)
                    Text(CurrencyFormatter.format(latestNetWorth))
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .monospacedDigit().foregroundStyle(AppTheme.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("YoY")
                        .font(.system(size: 11, weight: .heavy)).tracking(11 * 0.06)
                        .foregroundStyle(AppTheme.textTertiary)
                    Text(String(format: "%+.1f%%", yoyPct * 100))
                        .font(.system(size: 16, weight: .bold)).monospacedDigit()
                        .foregroundStyle(yoyGain >= 0 ? AppTheme.mint : AppTheme.coral)
                }
            }

            NetWorthAreaChart(snapshots: snapshots)

            // Range pills
            HStack(spacing: 6) {
                ForEach(Array(ranges.enumerated()), id: \.offset) { i, label in
                    Button { selectedRange = i } label: {
                        Text(label)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(selectedRange == i ? AppTheme.mint : AppTheme.textTertiary)
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(
                                selectedRange == i
                                ? AppTheme.mint.opacity(0.15)
                                : AppTheme.surface3,
                                in: Capsule()
                            )
                            .overlay(Capsule().stroke(
                                selectedRange == i ? AppTheme.mint.opacity(0.4) : AppTheme.hairline,
                                lineWidth: 0.5
                            ))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(AppTheme.cardPadding)
        .darkCard()
    }

    // MARK: - Save snapshot button
    private var snapshotButton: some View {
        Button {
            pendingNote = ""
            showNotePrompt = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 16, weight: .semibold))
                Text("Save Snapshot · \(DateHelpers.shortDisplayString(month: DateHelpers.currentMonth(), year: DateHelpers.currentYear()))")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(AppTheme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.mint, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Stats grid (3 columns)
    private var statsGrid: some View {
        let avg = snapshots.count > 0 ? yoyGain / Double(snapshots.count) : 0
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            MiniStatWidget(icon: "chart.line.uptrend.xyaxis", label: "12mo Gain",    value: CurrencyFormatter.formatCompact(yoyGain), accentColor: AppTheme.mint)
            MiniStatWidget(icon: "arrow.up.right",            label: "Snapshots",    value: "\(snapshots.count)",                     accentColor: AppTheme.violet)
            MiniStatWidget(icon: "chart.bar",                 label: "Avg / snap",   value: CurrencyFormatter.formatCompact(avg),     accentColor: AppTheme.cyan)
        }
    }

    // MARK: - Timeline
    private var timeline: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("TIMELINE")
                    .font(.system(size: 12, weight: .heavy)).tracking(12 * 0.08)
                    .foregroundStyle(AppTheme.textTertiary)
                Spacer()
                Text("\(snapshots.count) snapshots")
                    .font(.system(size: 11)).foregroundStyle(AppTheme.textTertiary)
            }

            if snapshots.isEmpty {
                VStack {
                    EmptyStateView(
                        systemImage: "clock.arrow.circlepath",
                        title: "No Snapshots Yet",
                        subtitle: "Save a snapshot to start tracking your net worth history"
                    )
                }
                .padding(AppTheme.cardPadding)
                .darkCard()
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(snapshots.enumerated()), id: \.element.id) { i, snap in
                        let prev: Double? = i < snapshots.count - 1 ? snapshots[i + 1].netWorth : nil
                        SnapshotRowView(snapshot: snap, previousNetWorth: prev)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) { modelContext.delete(snap) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
    }

    private func saveSnapshot() {
        let snapshot = NetWorthSnapshot(
            displayMonth:     DateHelpers.currentMonth(),
            displayYear:      DateHelpers.currentYear(),
            totalAssets:      totalAssets,
            totalLiabilities: totalLiabilities,
            note:             pendingNote.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(snapshot)
    }
}
