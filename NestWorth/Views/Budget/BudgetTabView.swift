import SwiftUI
import SwiftData

struct BudgetTabView: View {
    @State private var selectedMonth = DateHelpers.currentMonth()
    @State private var selectedYear = DateHelpers.currentYear()
    @State private var showAddIncome = false
    @State private var showAddExpense = false
    @State private var editingIncome: IncomeEntry? = nil
    @State private var editingExpense: ExpenseEntry? = nil

    @Query private var allIncome: [IncomeEntry]
    @Query private var allExpenses: [ExpenseEntry]

    private var filteredIncome: [IncomeEntry] {
        allIncome.filter { $0.month == selectedMonth && $0.year == selectedYear }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var filteredExpenses: [ExpenseEntry] {
        allExpenses.filter { $0.month == selectedMonth && $0.year == selectedYear }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var totalIncome: Double { filteredIncome.reduce(0) { $0 + $1.amount } }
    private var totalExpenses: Double { filteredExpenses.reduce(0) { $0 + $1.amount } }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    MonthYearPicker(month: $selectedMonth, year: $selectedYear)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .frame(maxWidth: .infinity)
                }

                Section {
                    BudgetSummaryCard(income: totalIncome, expenses: totalExpenses)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }

                Section {
                    if filteredIncome.isEmpty {
                        EmptyStateView(
                            systemImage: "arrow.down.circle",
                            title: "No Income",
                            subtitle: "Tap + to add income for \(DateHelpers.shortDisplayString(month: selectedMonth, year: selectedYear))",
                            actionLabel: "Add Income"
                        ) { showAddIncome = true }
                    } else {
                        ForEach(filteredIncome) { entry in
                            EntryRow(
                                title: entry.title,
                                subtitle: entry.note.isEmpty ? nil : entry.note,
                                amount: entry.amount,
                                icon: entry.source.icon,
                                iconColor: .blue,
                                amountColor: .green
                            )
                            .contentShape(Rectangle())
                            .onTapGesture { editingIncome = entry }
                        }
                        .onDelete(perform: deleteIncome)
                    }
                } header: {
                    HStack {
                        Text("Income")
                        Spacer()
                        Button { showAddIncome = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                }

                Section {
                    if filteredExpenses.isEmpty {
                        EmptyStateView(
                            systemImage: "arrow.up.circle",
                            title: "No Expenses",
                            subtitle: "Tap + to add expenses for \(DateHelpers.shortDisplayString(month: selectedMonth, year: selectedYear))",
                            actionLabel: "Add Expense"
                        ) { showAddExpense = true }
                    } else {
                        ForEach(filteredExpenses) { entry in
                            EntryRow(
                                title: entry.title,
                                subtitle: entry.note.isEmpty ? nil : entry.note,
                                amount: entry.amount,
                                icon: entry.category.icon,
                                iconColor: entry.category.color,
                                amountColor: .red
                            )
                            .contentShape(Rectangle())
                            .onTapGesture { editingExpense = entry }
                        }
                        .onDelete(perform: deleteExpense)
                    }
                } header: {
                    HStack {
                        Text("Expenses")
                        Spacer()
                        Button { showAddExpense = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Budget")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showAddIncome = true } label: {
                            Label("Add Income", systemImage: "arrow.down.circle")
                        }
                        Button { showAddExpense = true } label: {
                            Label("Add Expense", systemImage: "arrow.up.circle")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeSheet(month: selectedMonth, year: selectedYear)
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseSheet(month: selectedMonth, year: selectedYear)
            }
            .sheet(item: $editingIncome) { entry in
                AddIncomeSheet(month: selectedMonth, year: selectedYear, existing: entry)
            }
            .sheet(item: $editingExpense) { entry in
                AddExpenseSheet(month: selectedMonth, year: selectedYear, existing: entry)
            }
        }
    }

    @Environment(\.modelContext) private var modelContext

    private func deleteIncome(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredIncome[index])
        }
    }

    private func deleteExpense(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredExpenses[index])
        }
    }
}

private struct EntryRow: View {
    let title: String
    let subtitle: String?
    let amount: Double
    let icon: String
    let iconColor: Color
    let amountColor: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(CurrencyFormatter.format(amount))
                .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                .foregroundStyle(amountColor)
        }
        .padding(.vertical, 2)
    }
}
