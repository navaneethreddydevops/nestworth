import SwiftData
import Foundation

@Model
final class ExpenseEntry {
    var id: UUID
    var title: String
    var amount: Double
    var category: ExpenseCategory
    var month: Int
    var year: Int
    var createdAt: Date
    var note: String

    init(
        title: String,
        amount: Double,
        category: ExpenseCategory,
        month: Int,
        year: Int,
        note: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.category = category
        self.month = month
        self.year = year
        self.createdAt = Date()
        self.note = note
    }
}
