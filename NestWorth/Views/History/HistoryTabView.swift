import SwiftUI
import SwiftData

struct HistoryTabView: View {
    @Query(sort: \NetWorthSnapshot.snapshotDate, order: .reverse) private var snapshots: [NetWorthSnapshot]
    @Query private var assets: [Asset]
    @Query private var liabilities: [Liability]

    @Environment(\.modelContext) private var modelContext

    @State private var showNotePrompt = false
    @State private var pendingNote = ""

    private var totalAssets: Double { assets.reduce(0) { $0 + $1.value } }
    private var totalLiabilities: Double { liabilities.reduce(0) { $0 + $1.balance } }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        pendingNote = ""
                        showNotePrompt = true
                    } label: {
                        HStack {
                            Image(systemName: "camera.viewfinder")
                            Text("Save Current Snapshot")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                if snapshots.isEmpty {
                    Section {
                        EmptyStateView(
                            systemImage: "clock.arrow.circlepath",
                            title: "No Snapshots Yet",
                            subtitle: "Save a snapshot to track your net worth over time"
                        )
                    }
                } else {
                    Section("Snapshots") {
                        ForEach(Array(snapshots.enumerated()), id: \.element.id) { index, snapshot in
                            let previousNetWorth: Double? = index < snapshots.count - 1 ? snapshots[index + 1].netWorth : nil
                            SnapshotRowView(snapshot: snapshot, previousNetWorth: previousNetWorth)
                        }
                        .onDelete(perform: deleteSnapshot)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("History")
            .alert("Snapshot Note", isPresented: $showNotePrompt) {
                TextField("Optional note...", text: $pendingNote)
                Button("Save") { saveSnapshot() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Add an optional note to this snapshot.")
            }
        }
    }

    private func saveSnapshot() {
        let snapshot = NetWorthSnapshot(
            displayMonth: DateHelpers.currentMonth(),
            displayYear: DateHelpers.currentYear(),
            totalAssets: totalAssets,
            totalLiabilities: totalLiabilities,
            note: pendingNote.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(snapshot)
    }

    private func deleteSnapshot(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(snapshots[index]) }
    }
}
