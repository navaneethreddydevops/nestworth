import SwiftUI

extension IncomeSource {
    var themeColor: Color {
        switch self {
        case .salary:     return AppTheme.mint
        case .freelance:  return Color(hex: "#C4B5FD")
        case .rental:     return Color(hex: "#FDBA74")
        case .investment: return Color(hex: "#67E8F9")
        case .other:      return Color(hex: "#FCD34D")
        }
    }
}
