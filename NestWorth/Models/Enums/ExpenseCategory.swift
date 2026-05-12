import Foundation
import SwiftUI

enum ExpenseCategory: String, CaseIterable, Codable {
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
        case .housing:       return Color(red: 0.231, green: 0.510, blue: 0.965)
        case .food:          return Color(red: 0.976, green: 0.451, blue: 0.086)
        case .transport:     return Color(red: 0.063, green: 0.725, blue: 0.506)
        case .utilities:     return Color(red: 0.984, green: 0.749, blue: 0.141)
        case .entertainment: return Color(red: 0.545, green: 0.361, blue: 0.965)
        case .health:        return Color(red: 0.937, green: 0.267, blue: 0.267)
        case .education:     return Color(red: 0.024, green: 0.714, blue: 0.831)
        case .clothing:      return Color(red: 0.925, green: 0.251, blue: 0.600)
        case .other:         return Color(red: 0.612, green: 0.639, blue: 0.686)
        }
    }
}
