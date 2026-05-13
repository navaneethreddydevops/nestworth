import Foundation
import Observation

@Observable
final class BudgetViewModel {
    var selectedMonth: Int
    var selectedYear: Int

    init(month: Int = DateHelpers.currentMonth(), year: Int = DateHelpers.currentYear()) {
        self.selectedMonth = month
        self.selectedYear = year
    }

    func totalIncome(from entries: [IncomeEntry]) -> Double {
        filteredIncome(entries).reduce(0) { $0 + $1.amount }
    }

    func totalExpenses(from entries: [ExpenseEntry]) -> Double {
        filteredExpenses(entries).reduce(0) { $0 + $1.amount }
    }

    func savingsAmount(income: [IncomeEntry], expenses: [ExpenseEntry]) -> Double {
        totalIncome(from: income) - totalExpenses(from: expenses)
    }

    func savingsRate(income: [IncomeEntry], expenses: [ExpenseEntry]) -> Double {
        let inc = totalIncome(from: income)
        guard inc > 0 else { return 0 }
        return savingsAmount(income: income, expenses: expenses) / inc
    }

    func expensesByCategory(from entries: [ExpenseEntry]) -> [(category: ExpenseCategory, total: Double)] {
        var totals: [ExpenseCategory: Double] = [:]
        for entry in filteredExpenses(entries) {
            totals[entry.category, default: 0] += entry.amount
        }
        return totals
            .map { (category: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
    }

    private func filteredIncome(_ entries: [IncomeEntry]) -> [IncomeEntry] {
        entries.filter { $0.month == selectedMonth && $0.year == selectedYear }
    }

    private func filteredExpenses(_ entries: [ExpenseEntry]) -> [ExpenseEntry] {
        entries.filter { $0.month == selectedMonth && $0.year == selectedYear }
    }
}
