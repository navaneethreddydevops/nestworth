import SwiftData
import Foundation

@Model
final class IncomeEntry {
    var id: UUID
    var title: String
    var amount: Double
    var source: IncomeSource
    var month: Int
    var year: Int
    var createdAt: Date
    var note: String

    init(
        title: String,
        amount: Double,
        source: IncomeSource,
        month: Int,
        year: Int,
        note: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.source = source
        self.month = month
        self.year = year
        self.createdAt = Date()
        self.note = note
    }
}
