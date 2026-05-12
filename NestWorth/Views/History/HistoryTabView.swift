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

    private var totalAssets:      Double { assets.reduce(0)      { $0 + $1.value } }
    private var totalLiabilities: Double { liabilities.reduce(0) { $0 + $1.balance } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.sectionSpacing) {

                    // Hero area chart
                    GlassCard("Net Worth Over Time") {
                        NetWorthAreaChart(snapshots: snapshots)
                    }

                    // Save snapshot button
                    Button {
                        pendingNote = ""
                        showNotePrompt = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Save Current Snapshot")
                                .font(.subheadline.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                    }

                    // Timeline
                    if snapshots.isEmpty {
                        GlassCard {
                            EmptyStateView(
                                systemImage: "clock.arrow.circlepath",
                                title: "No Snapshots Yet",
                                subtitle: "Save a snapshot to start tracking your net worth history"
                            )
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Timeline")
                                .font(.headline)
                                .padding(.horizontal, 2)

                            ForEach(Array(snapshots.enumerated()), id: \.element.id) { index, snapshot in
                                let prev: Double? = index < snapshots.count - 1
                                    ? snapshots[index + 1].netWorth
                                    : nil
                                SnapshotRowView(snapshot: snapshot, previousNetWorth: prev)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            modelContext.delete(snapshot)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, AppTheme.cardPadding)
                .padding(.top, 8)
            }
            .background(AppTheme.background)
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .alert("Add a Note", isPresented: $showNotePrompt) {
                TextField("Optional note...", text: $pendingNote)
                Button("Save", action: saveSnapshot)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Optionally describe what changed this month.")
            }
        }
    }

    private func saveSnapshot() {
        let snapshot = NetWorthSnapshot(
            displayMonth:      DateHelpers.currentMonth(),
            displayYear:       DateHelpers.currentYear(),
            totalAssets:       totalAssets,
            totalLiabilities:  totalLiabilities,
            note:              pendingNote.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(snapshot)
    }
}
