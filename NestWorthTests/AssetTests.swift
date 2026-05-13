import Testing
import SwiftData
import Foundation
@testable import NestWorth

struct AssetTests {

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([Asset.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: config)
    }

    @Test func initializesWithDefaults() {
        let asset = Asset(name: "Checking", type: .checking, value: 5_000)
        #expect(asset.name == "Checking")
        #expect(asset.type == .checking)
        #expect(asset.value == 5_000)
        #expect(asset.note == "")
    }

    @Test func initializesWithNote() {
        let asset = Asset(name: "Home", type: .realEstate, value: 300_000, note: "Primary residence")
        #expect(asset.note == "Primary residence")
    }

    @Test func persistsAndFetches() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(Asset(name: "ETF Portfolio", type: .investment, value: 50_000))
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Asset>())
        #expect(fetched.count == 1)
        #expect(fetched[0].name == "ETF Portfolio")
        #expect(fetched[0].value == 50_000)
    }

    @Test func assetTypeIconsAreNonEmpty() {
        for type in AssetType.allCases {
            #expect(!type.icon.isEmpty)
        }
    }
}
