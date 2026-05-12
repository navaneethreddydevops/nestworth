import Foundation

enum DateHelpers {
    static func currentMonth() -> Int {
        Calendar.current.component(.month, from: Date())
    }

    static func currentYear() -> Int {
        Calendar.current.component(.year, from: Date())
    }

    static func monthName(_ month: Int) -> String {
        DateFormatter().monthSymbols[safe: month - 1] ?? "January"
    }

    static func shortMonthName(_ month: Int) -> String {
        DateFormatter().shortMonthSymbols[safe: month - 1] ?? "Jan"
    }

    static func displayString(month: Int, year: Int) -> String {
        "\(monthName(month)) \(year)"
    }

    static func shortDisplayString(month: Int, year: Int) -> String {
        let yearShort = year % 100
        return "\(shortMonthName(month)) '\(String(format: "%02d", yearShort))"
    }

    static func availableYears() -> [Int] {
        let current = currentYear()
        return Array((2020...current + 1))
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
