import Foundation
import Observation

@Observable
final class NetWorthViewModel {
    func totalAssets(from assets: [Asset]) -> Double {
        assets.reduce(0) { $0 + $1.value }
    }

    func totalLiabilities(from liabilities: [Liability]) -> Double {
        liabilities.reduce(0) { $0 + $1.balance }
    }

    func netWorth(assets: [Asset], liabilities: [Liability]) -> Double {
        totalAssets(from: assets) - totalLiabilities(from: liabilities)
    }

    func assetsByType(from assets: [Asset]) -> [(type: AssetType, total: Double)] {
        var totals: [AssetType: Double] = [:]
        for asset in assets {
            totals[asset.type, default: 0] += asset.value
        }
        return totals
            .map { (type: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
    }

    func liabilitiesByType(from liabilities: [Liability]) -> [(type: LiabilityType, total: Double)] {
        var totals: [LiabilityType: Double] = [:]
        for liability in liabilities {
            totals[liability.type, default: 0] += liability.balance
        }
        return totals
            .map { (type: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
    }
}
