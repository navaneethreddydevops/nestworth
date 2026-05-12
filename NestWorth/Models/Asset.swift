import SwiftData
import Foundation

@Model
final class Asset {
    var id: UUID
    var name: String
    var type: AssetType
    var value: Double
    var updatedAt: Date
    var note: String

    init(
        name: String,
        type: AssetType,
        value: Double,
        note: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.value = value
        self.updatedAt = Date()
        self.note = note
    }
}
