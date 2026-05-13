import Testing
import Foundation
@testable import NestWorth

struct NetWorthViewModelTests {

    private let vm = NetWorthViewModel()

    private func makeAsset(type: AssetType, value: Double) -> Asset {
        Asset(name: "Test", type: type, value: value)
    }

    private func makeLiability(type: LiabilityType, balance: Double) -> Liability {
        Liability(name: "Test", type: type, balance: balance)
    }

    @Test func totalAssetsSum() {
        let assets = [
            makeAsset(type: .checking, value: 10_000),
            makeAsset(type: .savings, value: 20_000),
            makeAsset(type: .investment, value: 30_000)
        ]
        #expect(vm.totalAssets(from: assets) == 60_000)
    }

    @Test func totalAssetsEmpty() {
        #expect(vm.totalAssets(from: []) == 0)
    }

    @Test func totalLiabilitiesSum() {
        let liabilities = [
            makeLiability(type: .creditCard, balance: 5_000),
            makeLiability(type: .mortgage, balance: 200_000)
        ]
        #expect(vm.totalLiabilities(from: liabilities) == 205_000)
    }

    @Test func netWorthPositive() {
        let assets = [makeAsset(type: .savings, value: 100_000)]
        let liabilities = [makeLiability(type: .studentLoan, balance: 30_000)]
        #expect(vm.netWorth(assets: assets, liabilities: liabilities) == 70_000)
    }

    @Test func netWorthNegative() {
        let assets = [makeAsset(type: .checking, value: 1_000)]
        let liabilities = [makeLiability(type: .creditCard, balance: 10_000)]
        #expect(vm.netWorth(assets: assets, liabilities: liabilities) == -9_000)
    }

    @Test func assetsByTypeSortedDescending() {
        let assets = [
            makeAsset(type: .checking, value: 5_000),
            makeAsset(type: .realEstate, value: 300_000),
            makeAsset(type: .investment, value: 50_000)
        ]
        let result = vm.assetsByType(from: assets)
        #expect(result[0].type == .realEstate)
        #expect(result[0].total == 300_000)
        #expect(result[1].type == .investment)
        #expect(result[2].type == .checking)
    }

    @Test func assetsByTypeAggregatesSameType() {
        let assets = [
            makeAsset(type: .savings, value: 10_000),
            makeAsset(type: .savings, value: 5_000)
        ]
        let result = vm.assetsByType(from: assets)
        #expect(result.count == 1)
        #expect(result[0].total == 15_000)
    }

    @Test func liabilitiesByTypeSortedDescending() {
        let liabilities = [
            makeLiability(type: .creditCard, balance: 3_000),
            makeLiability(type: .mortgage, balance: 250_000)
        ]
        let result = vm.liabilitiesByType(from: liabilities)
        #expect(result[0].type == .mortgage)
        #expect(result[1].type == .creditCard)
    }
}
