import Foundation

enum IncomeSource: String, CaseIterable, Codable {
    case salary = "Salary"
    case freelance = "Freelance"
    case rental = "Rental"
    case investment = "Investment"
    case other = "Other"

    var icon: String {
        switch self {
        case .salary:     return "briefcase"
        case .freelance:  return "laptopcomputer"
        case .rental:     return "house"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .other:      return "dollarsign.circle"
        }
    }

    var color: String {
        switch self {
        case .salary:     return "blue"
        case .freelance:  return "purple"
        case .rental:     return "orange"
        case .investment: return "green"
        case .other:      return "gray"
        }
    }
}
