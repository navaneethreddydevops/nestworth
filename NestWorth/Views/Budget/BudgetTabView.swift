import SwiftUI
import SwiftData

struct BudgetTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allIncome: [IncomeEntry]
    @Query private var allExpenses: [ExpenseEntry]

    @State private var selectedMonth = DateHelpers.currentMonth()
    @State private var selectedYear  = DateHelpers.currentYear()
    @State private var showAddIncome  = false
    @State private var showAddExpense = false
    @State private var editingIncome:  IncomeEntry? = nil
    @State private var editingExpense: ExpenseEntry? = nil

    private var filteredIncome: [IncomeEntry] {
        allIncome
            .filter { $0.month == selectedMonth && $0.year == selectedYear }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var filteredExpenses: [ExpenseEntry] {
        allExpenses
            .filter { $0.month == selectedMonth && $0.year == selectedYear }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var totalIncome:   Double { filteredIncome.reduce(0)   { $0 + $1.amount } }
    private var totalExpenses: Double { filteredExpenses.reduce(0) { $0 + $1.amount } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.sectionSpacing) {

                    // Month picker
                    MonthYearPicker(month: $selectedMonth, year: $selectedYear)
                        .frame(maxWidth: .infinity, alignment: .center)

                    // Summary card
                    BudgetSummaryCard(income: totalIncome, expenses: totalExpenses)

                    // Spending donut
                    GlassCard("Spending Breakdown") {
                        SpendingDonutChart(expenses: filteredExpenses)
                    }

                    // Bar chart
                    GlassCard("Income vs Expenses") {
                        BudgetBarChart(income: totalIncome, expenses: totalExpenses)
                    }

                    // Transactions
                    transactionSection(
                        title: "Income",
                        entries: filteredIncome.map { TransactionItem(from: $0) },
                        accentColor: AppTheme.income,
                        amountColor: AppTheme.income,
                        onAdd: { showAddIncome = true },
                        onTap: { id in editingIncome = filteredIncome.first { $0.id == id } },
                        onDelete: deleteIncome
                    )

                    transactionSection(
                        title: "Expenses",
                        entries: filteredExpenses.map { TransactionItem(from: $0) },
                        accentColor: AppTheme.expense,
                        amountColor: AppTheme.expense,
                        onAdd: { showAddExpense = true },
                        onTap: { id in editingExpense = filteredExpenses.first { $0.id == id } },
                        onDelete: deleteExpense
                    )

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, AppTheme.cardPadding)
                .padding(.top, 8)
            }
            .background(AppTheme.background)
            .navigationTitle("Budget")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showAddIncome  = true } label: { Label("Add Income",  systemImage: "arrow.down.circle") }
                        Button { showAddExpense = true } label: { Label("Add Expense", systemImage: "arrow.up.circle") }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showAddIncome)  { AddIncomeSheet(month: selectedMonth, year: selectedYear) }
            .sheet(isPresented: $showAddExpense) { AddExpenseSheet(month: selectedMonth, year: selectedYear) }
            .sheet(item: $editingIncome)  { AddIncomeSheet(month: selectedMonth,  year: selectedYear, existing: $0) }
            .sheet(item: $editingExpense) { AddExpenseSheet(month: selectedMonth, year: selectedYear, existing: $0) }
        }
    }

    // MARK: - Helpers

    private func deleteIncome(at offsets: IndexSet) {
        offsets.forEach { modelContext.delete(filteredIncome[$0]) }
    }

    private func deleteExpense(at offsets: IndexSet) {
        offsets.forEach { modelContext.delete(filteredExpenses[$0]) }
    }

    @ViewBuilder
    private func transactionSection(
        title: String,
        entries: [TransactionItem],
        accentColor: Color,
        amountColor: Color,
        onAdd: @escaping () -> Void,
        onTap: @escaping (UUID) -> Void,
        onDelete: @escaping (IndexSet) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section header
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(accentColor)
                        .font(.title3)
                }
            }
            .padding(.horizontal, 2)

            if entries.isEmpty {
                GlassCard {
                    EmptyStateView(
                        systemImage: title == "Income" ? "arrow.down.circle" : "arrow.up.circle",
                        title: "No \(title)",
                        subtitle: "Tap + to add \(title.lowercased()) for \(DateHelpers.shortDisplayString(month: selectedMonth, year: selectedYear))"
                    )
                }
            } else {
                // Use List for swipe-to-delete, styled to blend in
                List {
                    ForEach(entries) { item in
                        TransactionRow(item: item, amountColor: amountColor)
                            .contentShape(Rectangle())
                            .onTapGesture { onTap(item.id) }
                            .listRowBackground(AppTheme.surface)
                            .listRowSeparatorTint(Color(uiColor: .separator).opacity(0.4))
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                    .onDelete(perform: onDelete)
                }
                .listStyle(.plain)
                .scrollDisabled(true)
                .frame(height: CGFloat(entries.count) * 64)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            }
        }
    }
}

// MARK: - View Models

private struct TransactionItem: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String?
    let amount: Double
    let icon: String
    let iconColor: Color

    init(from entry: IncomeEntry) {
        id       = entry.id
        title    = entry.title
        subtitle = entry.note.isEmpty ? nil : entry.note
        amount   = entry.amount
        icon     = entry.source.icon
        iconColor = entry.source.themeColor
    }

    init(from entry: ExpenseEntry) {
        id        = entry.id
        title     = entry.title
        subtitle  = entry.note.isEmpty ? nil : entry.note
        amount    = entry.amount
        icon      = entry.category.icon
        iconColor = entry.category.color
    }
}

private struct TransactionRow: View {
    let item: TransactionItem
    let amountColor: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(item.iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: item.icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(item.iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            AnimatedCurrencyText(amount: item.amount, font: .subheadline.weight(.semibold), color: amountColor)
        }
        .padding(.vertical, 12)
    }
}
