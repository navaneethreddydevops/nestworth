import Foundation
import SwiftUI

enum LiabilityType: String, CaseIterable, Codable {
    case creditCard = "Credit Card"
    case personalLoan = "Personal Loan"
    case studentLoan = "Student Loan"
    case autoLoan = "Auto Loan"
    case mortgage = "Mortgage"
    case other = "Other"

    var icon: String {
        switch self {
        case .creditCard:   return "creditcard.fill"
        case .personalLoan: return "person.badge.minus"
        case .studentLoan:  return "graduationcap.fill"
        case .autoLoan:     return "car.fill"
        case .mortgage:     return "house.fill"
        case .other:        return "minus.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .creditCard:   return Color(hex: "#FCA5A5")
        case .personalLoan: return Color(hex: "#FCD34D")
        case .studentLoan:  return Color(hex: "#67E8F9")
        case .autoLoan:     return Color(hex: "#C4B5FD")
        case .mortgage:     return Color(hex: "#FDBA74")
        case .other:        return Color(hex: "#94A3B8")
        }
    }
}
