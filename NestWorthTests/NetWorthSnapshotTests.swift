import Testing
import SwiftData
import Foundation
@testable import NestWorth

struct NetWorthSnapshotTests {

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([NetWorthSnapshot.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: config)
    }

    @Test func netWorthIsComputedCorrectly() {
        let snapshot = NetWorthSnapshot(
            displayMonth: 1,
            displayYear: 2025,
            totalAssets: 100_000,
            totalLiabilities: 30_000
        )
        #expect(snapshot.netWorth == 70_000)
    }

    @Test func netWorthUpdatesWhenAssetsChange() {
        let snapshot = NetWorthSnapshot(
            displayMonth: 1,
            displayYear: 2025,
            totalAssets: 100_000,
            totalLiabilities: 30_000
        )
        snapshot.totalAssets = 120_000
        #expect(snapshot.netWorth == 90_000)
    }

    @Test func netWorthUpdatesWhenLiabilitiesChange() {
        let snapshot = NetWorthSnapshot(
            displayMonth: 1,
            displayYear: 2025,
            totalAssets: 100_000,
            totalLiabilities: 30_000
        )
        snapshot.totalLiabilities = 50_000
        #expect(snapshot.netWorth == 50_000)
    }

    @Test func netWorthCanBeNegative() {
        let snapshot = NetWorthSnapshot(
            displayMonth: 6,
            displayYear: 2025,
            totalAssets: 10_000,
            totalLiabilities: 50_000
        )
        #expect(snapshot.netWorth == -40_000)
    }

    @Test func netWorthZeroWhenBalanced() {
        let snapshot = NetWorthSnapshot(
            displayMonth: 3,
            displayYear: 2025,
            totalAssets: 50_000,
            totalLiabilities: 50_000
        )
        #expect(snapshot.netWorth == 0)
    }

    @Test func persistsToInMemoryStore() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let snapshot = NetWorthSnapshot(
            displayMonth: 5,
            displayYear: 2025,
            totalAssets: 200_000,
            totalLiabilities: 80_000
        )
        context.insert(snapshot)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<NetWorthSnapshot>())
        #expect(fetched.count == 1)
        #expect(fetched[0].netWorth == 120_000)
    }

    @Test func noteDefaultsToEmpty() {
        let snapshot = NetWorthSnapshot(
            displayMonth: 1,
            displayYear: 2025,
            totalAssets: 0,
            totalLiabilities: 0
        )
        #expect(snapshot.note == "")
    }
}
