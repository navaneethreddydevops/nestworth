import Testing
import Foundation
@testable import NestWorth

struct BudgetViewModelTests {

    private func vm(month: Int = 5, year: Int = 2025) -> BudgetViewModel {
        BudgetViewModel(month: month, year: year)
    }

    private func makeIncome(amount: Double, source: IncomeSource = .salary, month: Int = 5, year: Int = 2025) -> IncomeEntry {
        IncomeEntry(title: "Test", amount: amount, source: source, month: month, year: year)
    }

    private func makeExpense(amount: Double, category: ExpenseCategory = .food, month: Int = 5, year: Int = 2025) -> ExpenseEntry {
        ExpenseEntry(title: "Test", amount: amount, category: category, month: month, year: year)
    }

    @Test func totalIncomeForSelectedMonth() {
        let budgetVM = vm()
        let entries = [
            makeIncome(amount: 5_000),
            makeIncome(amount: 1_000)
        ]
        #expect(budgetVM.totalIncome(from: entries) == 6_000)
    }

    @Test func totalIncomeFiltersOtherMonths() {
        let budgetVM = vm(month: 5, year: 2025)
        let entries = [
            makeIncome(amount: 5_000, month: 5, year: 2025),
            makeIncome(amount: 1_000, month: 4, year: 2025)  // different month
        ]
        #expect(budgetVM.totalIncome(from: entries) == 5_000)
    }

    @Test func totalIncomeFiltersOtherYears() {
        let budgetVM = vm(month: 5, year: 2025)
        let entries = [
            makeIncome(amount: 5_000, month: 5, year: 2025),
            makeIncome(amount: 1_000, month: 5, year: 2024)  // different year
        ]
        #expect(budgetVM.totalIncome(from: entries) == 5_000)
    }

    @Test func totalExpensesForSelectedMonth() {
        let budgetVM = vm()
        let entries = [
            makeExpense(amount: 1_200),
            makeExpense(amount: 300)
        ]
        #expect(budgetVM.totalExpenses(from: entries) == 1_500)
    }

    @Test func savingsAmountPositive() {
        let budgetVM = vm()
        let income = [makeIncome(amount: 5_000)]
        let expenses = [makeExpense(amount: 2_000)]
        #expect(budgetVM.savingsAmount(income: income, expenses: expenses) == 3_000)
    }

    @Test func savingsAmountNegativeWhenOverspent() {
        let budgetVM = vm()
        let income = [makeIncome(amount: 2_000)]
        let expenses = [makeExpense(amount: 3_000)]
        #expect(budgetVM.savingsAmount(income: income, expenses: expenses) == -1_000)
    }

    @Test func savingsRateCalculation() {
        let budgetVM = vm()
        let income = [makeIncome(amount: 5_000)]
        let expenses = [makeExpense(amount: 2_000)]
        let rate = budgetVM.savingsRate(income: income, expenses: expenses)
        #expect(abs(rate - 0.6) < 0.0001)
    }

    @Test func savingsRateZeroWhenNoIncome() {
        let budgetVM = vm()
        let rate = budgetVM.savingsRate(income: [], expenses: [makeExpense(amount: 500)])
        #expect(rate == 0)
    }

    @Test func expensesByCategoryAggregates() {
        let budgetVM = vm()
        let expenses = [
            makeExpense(amount: 500, category: .food),
            makeExpense(amount: 300, category: .food),
            makeExpense(amount: 1_200, category: .housing)
        ]
        let result = budgetVM.expensesByCategory(from: expenses)
        let housing = result.first { $0.category == .housing }
        let food = result.first { $0.category == .food }
        #expect(housing?.total == 1_200)
        #expect(food?.total == 800)
    }

    @Test func expensesByCategorySortedDescending() {
        let budgetVM = vm()
        let expenses = [
            makeExpense(amount: 100, category: .entertainment),
            makeExpense(amount: 1_500, category: .housing),
            makeExpense(amount: 500, category: .food)
        ]
        let result = budgetVM.expensesByCategory(from: expenses)
        #expect(result[0].category == .housing)
        #expect(result[1].category == .food)
        #expect(result[2].category == .entertainment)
    }

    @Test func expensesByCategoryFiltersOtherMonths() {
        let budgetVM = vm(month: 5, year: 2025)
        let expenses = [
            makeExpense(amount: 500, category: .food, month: 5, year: 2025),
            makeExpense(amount: 999, category: .housing, month: 4, year: 2025)
        ]
        let result = budgetVM.expensesByCategory(from: expenses)
        #expect(result.count == 1)
        #expect(result[0].category == .food)
    }
}
