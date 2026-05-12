import SwiftData
import Foundation

@Model
final class Liability {
    var id: UUID
    var name: String
    var type: LiabilityType
    var balance: Double
    var updatedAt: Date
    var note: String

    init(
        name: String,
        type: LiabilityType,
        balance: Double,
        note: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.balance = balance
        self.updatedAt = Date()
        self.note = note
    }
}
