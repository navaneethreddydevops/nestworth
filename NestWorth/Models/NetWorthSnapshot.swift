import SwiftData
import Foundation

@Model
final class NetWorthSnapshot {
    var id: UUID
    var snapshotDate: Date
    var displayMonth: Int
    var displayYear: Int
    var totalAssets: Double
    var totalLiabilities: Double
    var note: String

    var netWorth: Double { totalAssets - totalLiabilities }

    init(
        snapshotDate: Date = Date(),
        displayMonth: Int,
        displayYear: Int,
        totalAssets: Double,
        totalLiabilities: Double,
        note: String = ""
    ) {
        self.id = UUID()
        self.snapshotDate = snapshotDate
        self.displayMonth = displayMonth
        self.displayYear = displayYear
        self.totalAssets = totalAssets
        self.totalLiabilities = totalLiabilities
        self.note = note
    }
}
