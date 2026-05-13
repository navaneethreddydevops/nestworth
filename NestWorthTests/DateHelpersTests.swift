import Testing
import Foundation
@testable import NestWorth

struct DateHelpersTests {

    @Test func currentMonthIsValid() {
        let month = DateHelpers.currentMonth()
        #expect((1...12).contains(month))
    }

    @Test func currentYearIsReasonable() {
        let year = DateHelpers.currentYear()
        #expect(year >= 2024)
    }

    @Test func monthNameJanuary() {
        #expect(DateHelpers.monthName(1) == "January")
    }

    @Test func monthNameDecember() {
        #expect(DateHelpers.monthName(12) == "December")
    }

    @Test func monthNameInvalidFallback() {
        #expect(DateHelpers.monthName(0) == "January")
        #expect(DateHelpers.monthName(13) == "January")
    }

    @Test func shortMonthNameJanuary() {
        #expect(DateHelpers.shortMonthName(1) == "Jan")
    }

    @Test func shortMonthNameJuly() {
        #expect(DateHelpers.shortMonthName(7) == "Jul")
    }

    @Test func displayStringFormat() {
        let result = DateHelpers.displayString(month: 3, year: 2025)
        #expect(result == "March 2025")
    }

    @Test func shortDisplayStringFormat() {
        let result = DateHelpers.shortDisplayString(month: 1, year: 2025)
        #expect(result == "Jan '25")
    }

    @Test func availableYearsContainsCurrent() {
        let years = DateHelpers.availableYears()
        let current = DateHelpers.currentYear()
        #expect(years.contains(current))
    }

    @Test func availableYearsStartFrom2020() {
        let years = DateHelpers.availableYears()
        #expect(years.first == 2020)
    }

    @Test func availableYearsIncludesNextYear() {
        let years = DateHelpers.availableYears()
        let next = DateHelpers.currentYear() + 1
        #expect(years.contains(next))
    }
}
