import Testing
import SwiftData
import Foundation
@testable import NestWorth

struct LiabilityTests {

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([Liability.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: config)
    }

    @Test func initializesWithDefaults() {
        let liability = Liability(name: "Visa", type: .creditCard, balance: 2_500)
        #expect(liability.name == "Visa")
        #expect(liability.type == .creditCard)
        #expect(liability.balance == 2_500)
        #expect(liability.note == "")
    }

    @Test func persistsAndFetches() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(Liability(name: "Home Loan", type: .mortgage, balance: 350_000))
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Liability>())
        #expect(fetched.count == 1)
        #expect(fetched[0].type == .mortgage)
    }

    @Test func liabilityTypeIconsAreNonEmpty() {
        for type in LiabilityType.allCases {
            #expect(!type.icon.isEmpty)
        }
    }
}
