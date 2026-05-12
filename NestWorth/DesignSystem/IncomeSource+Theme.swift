import SwiftUI

extension IncomeSource {
    var themeColor: Color {
        switch self {
        case .salary:     return AppTheme.accent
        case .freelance:  return Color(red: 0.545, green: 0.361, blue: 0.965)
        case .rental:     return Color(red: 0.984, green: 0.549, blue: 0.086)
        case .investment: return AppTheme.income
        case .other:      return AppTheme.neutral
        }
    }
}
