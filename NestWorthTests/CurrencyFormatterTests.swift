import Testing
@testable import NestWorth

struct CurrencyFormatterTests {

    @Test func formatPositiveValue() {
        let result = CurrencyFormatter.format(1234.56)
        #expect(result.contains("1,234.56") || result.contains("1234.56"))
    }

    @Test func formatZero() {
        let result = CurrencyFormatter.format(0)
        #expect(result.contains("0.00"))
    }

    @Test func formatNegativeValue() {
        let result = CurrencyFormatter.format(-500.0)
        #expect(result.contains("500.00"))
    }

    @Test func formatCompactMillions() {
        let result = CurrencyFormatter.formatCompact(2_500_000)
        #expect(result == "$2.5M")
    }

    @Test func formatCompactThousands() {
        let result = CurrencyFormatter.formatCompact(75_000)
        #expect(result == "$75.0k")
    }

    @Test func formatCompactSmallValue() {
        let result = CurrencyFormatter.formatCompact(999)
        #expect(result.contains("999"))
    }

    @Test func formatCompactExactlyOneMillion() {
        let result = CurrencyFormatter.formatCompact(1_000_000)
        #expect(result == "$1.0M")
    }

    @Test func formatCompactExactlyOneThousand() {
        let result = CurrencyFormatter.formatCompact(1_000)
        #expect(result == "$1.0k")
    }

    @Test func formatCompactNegativeThousands() {
        let result = CurrencyFormatter.formatCompact(-50_000)
        #expect(result == "$-50.0k")
    }
}
