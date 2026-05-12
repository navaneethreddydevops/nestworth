import Foundation

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
}
