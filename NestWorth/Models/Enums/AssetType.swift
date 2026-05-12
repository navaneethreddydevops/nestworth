import Foundation

enum AssetType: String, CaseIterable, Codable {
    case checking = "Checking Account"
    case savings = "Savings Account"
    case investment = "Investments / Stocks"
    case realEstate = "Real Estate"
    case vehicle = "Vehicle"
    case retirement = "Retirement Account"
    case other = "Other"

    var icon: String {
        switch self {
        case .checking:   return "creditcard"
        case .savings:    return "banknote"
        case .investment: return "chart.bar.fill"
        case .realEstate: return "house.fill"
        case .vehicle:    return "car.fill"
        case .retirement: return "umbrella.fill"
        case .other:      return "archivebox.fill"
        }
    }
}
