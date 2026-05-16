import Foundation
import SwiftUI

enum ExpenseCategory: String, CaseIterable, Codable, Identifiable {
    var id: String { rawValue }
    case housing = "Housing"
    case food = "Food"
    case transport = "Transport"
    case utilities = "Utilities"
    case entertainment = "Entertainment"
    case health = "Health"
    case education = "Education"
    case clothing = "Clothing"
    case other = "Other"

    var icon: String {
        switch self {
        case .housing:       return "house"
        case .food:          return "fork.knife"
        case .transport:     return "car"
        case .utilities:     return "bolt"
        case .entertainment: return "tv"
        case .health:        return "heart.circle"
        case .education:     return "book"
        case .clothing:      return "tshirt"
        case .other:         return "tag"
        }
    }

    var color: Color {
        switch self {
        case .housing:       return Color(hex: "#93C5FD")
        case .food:          return Color(hex: "#FCD34D")
        case .transport:     return Color(hex: "#5EEAD4")
        case .utilities:     return Color(hex: "#FDBA74")
        case .entertainment: return Color(hex: "#C4B5FD")
        case .health:        return Color(hex: "#FCA5A5")
        case .education:     return Color(hex: "#67E8F9")
        case .clothing:      return Color(hex: "#F0ABFC")
        case .other:         return Color(hex: "#94A3B8")
        }
    }
}
