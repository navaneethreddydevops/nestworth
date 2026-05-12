import Foundation

enum CurrencyFormatter {
    static let shared: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = .current
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    static func format(_ value: Double) -> String {
        shared.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    static func formatCompact(_ value: Double) -> String {
        if abs(value) >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if abs(value) >= 1_000 {
            return String(format: "$%.1fk", value / 1_000)
        }
        return format(value)
    }
}
