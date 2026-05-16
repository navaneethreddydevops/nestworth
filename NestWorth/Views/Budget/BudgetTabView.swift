import SwiftUI
import SwiftData

struct BudgetTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allIncome:   [IncomeEntry]
    @Query private var allExpenses: [ExpenseEntry]

    @State private var selectedMonth = DateHelpers.currentMonth()
    @State private var selectedYear  = DateHelpers.currentYear()
    @State private var showAddIncome  = false
    @State private var showAddExpense = false
    @State private var editingIncome:  IncomeEntry? = nil
    @State private var editingExpense: ExpenseEntry? = nil
    @State private var selectedCategory: ExpenseCategory? = nil

    private var filteredIncome: [IncomeEntry] {
        allIncome.filter { $0.month == selectedMonth && $0.year == selectedYear }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var filteredExpenses: [ExpenseEntry] {
        allExpenses.filter { $0.month == selectedMonth && $0.year == selectedYear }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var totalIncome:   Double { filteredIncome.reduce(0)   { $0 + $1.amount } }
    private var totalExpenses: Double { filteredExpenses.reduce(0) { $0 + $1.amount } }
    private var savings:       Double { totalIncome - totalExpenses }
    private var savingsRate:   Double { totalIncome > 0 ? max(0, savings / totalIncome) : 0 }

    // Category breakdown sorted by amount descending
    private struct CategoryGroup: Identifiable {
        let id = UUID()
        let category: ExpenseCategory
        let amount: Double
        let count: Int
    }

    private var categoryGroups: [CategoryGroup] {
        let grouped = Dictionary(grouping: filteredExpenses, by: \.category)
        return grouped.map { cat, entries in
            CategoryGroup(category: cat, amount: entries.reduce(0) { $0 + $1.amount }, count: entries.count)
        }.sorted { $0.amount > $1.amount }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.sectionSpacing) {
                header
                arcCard
                if !categoryGroups.isEmpty { breakdownCard }
                incomeVsExpensesCard
                transactionSection(
                    title: "Income", count: filteredIncome.count,
                    entries: filteredIncome.map { TransactionItem(from: $0) },
                    amountColor: AppTheme.mint, sign: "+",
                    onAdd: { showAddIncome = true },
                    onTap: { id in editingIncome = filteredIncome.first { $0.id == id } },
                    onDelete: deleteIncome
                )
                transactionSection(
                    title: "Expenses", count: filteredExpenses.count,
                    entries: filteredExpenses.map { TransactionItem(from: $0) },
                    amountColor: AppTheme.coral, sign: "−",
                    onAdd: { showAddExpense = true },
                    onTap: { id in editingExpense = filteredExpenses.first { $0.id == id } },
                    onDelete: deleteExpense
                )
            }
            .padding(.horizontal, AppTheme.cardPadding)
            .padding(.top, 56)
        }
        .background(appBackground)
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 90) }
        .sheet(isPresented: $showAddIncome)  { AddIncomeSheet(month: selectedMonth, year: selectedYear) }
        .sheet(isPresented: $showAddExpense) { AddExpenseSheet(month: selectedMonth, year: selectedYear) }
        .sheet(item: $editingIncome)  { AddIncomeSheet(month: selectedMonth,  year: selectedYear, existing: $0) }
        .sheet(item: $editingExpense) { AddExpenseSheet(month: selectedMonth, year: selectedYear, existing: $0) }
        .sheet(item: $selectedCategory) { category in
            CategoryDetailView(
                category: category,
                expenses: filteredExpenses.filter { $0.category == category },
                month: selectedMonth, year: selectedYear
            )
        }
    }

    private var appBackground: some View {
        ZStack {
            AppTheme.background
            RadialGradient(colors: [AppTheme.mint.opacity(0.06), .clear], center: .top, startRadius: 0, endRadius: 300)
        }.ignoresSafeArea()
    }

    // MARK: - Header
    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("BUDGET")
                    .font(.system(size: 11, weight: .heavy)).tracking(11 * 0.08)
                    .foregroundStyle(AppTheme.textTertiary)
                Text(DateHelpers.displayString(month: selectedMonth, year: selectedYear))
                    .font(.system(size: 28, weight: .bold)).tracking(-0.02 * 28)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            Spacer()
            MonthYearPicker(month: $selectedMonth, year: $selectedYear)
        }
    }

    // MARK: - Spending arc card
    private var arcCard: some View {
        HStack(alignment: .center, spacing: 18) {
            CircularProgressRing(
                progress: totalIncome > 0 ? min(totalExpenses / totalIncome, 1) : 0,
                gradient: AppTheme.mintVioletGradient,
                lineWidth: 13, size: 120,
                label: CurrencyFormatter.formatCompact(totalExpenses),
                sublabel: "spent"
            )

            VStack(alignment: .leading, spacing: 6) {
                arcRow(dot: AppTheme.mint,   label: "Income",    value: CurrencyFormatter.formatCompact(totalIncome),   color: AppTheme.mint)
                arcRow(dot: AppTheme.violet, label: "Net",       value: CurrencyFormatter.formatCompact(savings),       color: AppTheme.violet)
                arcRow(dot: AppTheme.cyan,   label: "Save rate", value: "\(Int(savingsRate * 100))%",                   color: AppTheme.cyan)
            }
        }
        .padding(AppTheme.cardPadding)
        .darkCard()
    }

    @ViewBuilder
    private func arcRow(dot: Color, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(dot).frame(width: 8, height: 8)
            Text(label).font(.system(size: 11)).foregroundStyle(AppTheme.textTertiary)
            Spacer()
            Text(value).font(.system(size: 12, weight: .bold)).monospacedDigit().foregroundStyle(color)
        }
    }

    // MARK: - Category breakdown
    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("WHERE IT WENT")
                    .font(.system(size: 12, weight: .heavy)).tracking(12 * 0.08)
                    .foregroundStyle(AppTheme.textTertiary)
                Spacer()
                Text("\(categoryGroups.count) categories")
                    .font(.system(size: 11)).foregroundStyle(AppTheme.textTertiary)
            }

            let maxAmt = categoryGroups.first?.amount ?? 1
            let total  = totalExpenses > 0 ? totalExpenses : 1

            VStack(spacing: 12) {
                ForEach(categoryGroups) { group in
                    CategoryBreakdownRow(
                        icon: group.category.icon,
                        name: group.category.rawValue,
                        color: group.category.color,
                        amount: group.amount,
                        fraction: group.amount / maxAmt,
                        count: group.count,
                        sharePct: group.amount / total * 100
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { selectedCategory = group.category }
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .darkCard()
    }

    // MARK: - Income vs Expenses
    private var incomeVsExpensesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("INCOME VS EXPENSES")
                .font(.system(size: 12, weight: .heavy)).tracking(12 * 0.08)
                .foregroundStyle(AppTheme.textTertiary)

            let maxVal = max(totalIncome, totalExpenses, 1)
            VStack(spacing: 10) {
                stackedBar(label: "Income",   value: totalIncome,   max: maxVal, color: AppTheme.mint)
                stackedBar(label: "Expenses", value: totalExpenses, max: maxVal, color: AppTheme.coral)
                stackedBar(label: "Saved",    value: max(savings, 0), max: maxVal, color: AppTheme.violet)
            }
        }
        .padding(AppTheme.cardPadding)
        .darkCard()
    }

    @ViewBuilder
    private func stackedBar(label: String, value: Double, max maxVal: Double, color: Color) -> some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 12)).foregroundStyle(AppTheme.textTertiary)
                .frame(width: 60, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppTheme.surface3).frame(height: 8)
                    Capsule().fill(color)
                        .frame(width: max(0, geo.size.width * CGFloat(value / maxVal)), height: 8)
                        .animation(.spring(duration: 0.5), value: value)
                }
            }
            .frame(height: 8)
            Text(CurrencyFormatter.formatCompact(value))
                .font(.system(size: 12, weight: .bold)).monospacedDigit()
                .foregroundStyle(color)
                .frame(width: 60, alignment: .trailing)
        }
    }

    // MARK: - Transaction section
    @ViewBuilder
    private func transactionSection(
        title: String, count: Int,
        entries: [TransactionItem],
        amountColor: Color, sign: String,
        onAdd: @escaping () -> Void,
        onTap: @escaping (UUID) -> Void,
        onDelete: @escaping (IndexSet) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(title.uppercased()) · \(count)")
                    .font(.system(size: 12, weight: .heavy)).tracking(12 * 0.08)
                    .foregroundStyle(AppTheme.textTertiary)
                Spacer()
                Button(action: onAdd) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus").font(.system(size: 12, weight: .bold))
                        Text("Add")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.mint)
                }
            }

            if entries.isEmpty {
                VStack {
                    EmptyStateView(
                        systemImage: title == "Income" ? "arrow.down.circle" : "arrow.up.circle",
                        title: "No \(title)",
                        subtitle: "Tap Add to record \(title.lowercased()) for \(DateHelpers.shortDisplayString(month: selectedMonth, year: selectedYear))"
                    )
                }
                .padding(AppTheme.cardPadding)
                .darkCard()
            } else {
                List {
                    ForEach(entries) { item in
                        TransactionRow(item: item, amountColor: amountColor, sign: sign)
                            .contentShape(Rectangle())
                            .onTapGesture { onTap(item.id) }
                            .listRowBackground(AppTheme.surface)
                            .listRowSeparatorTint(AppTheme.hairline)
                            .listRowInsets(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14))
                    }
                    .onDelete(perform: onDelete)
                }
                .listStyle(.plain)
                .scrollDisabled(true)
                .frame(height: CGFloat(entries.count) * 66)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                .overlay(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius).stroke(AppTheme.hairline, lineWidth: 0.5))
            }
        }
    }

    private func deleteIncome(at offsets: IndexSet)   { offsets.forEach { modelContext.delete(filteredIncome[$0]) } }
    private func deleteExpense(at offsets: IndexSet)  { offsets.forEach { modelContext.delete(filteredExpenses[$0]) } }
}

// MARK: - View models

private struct TransactionItem: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String?
    let amount: Double
    let icon: String
    let iconColor: Color

    init(from entry: IncomeEntry) {
        id = entry.id; title = entry.title
        subtitle = entry.note.isEmpty ? nil : entry.note
        amount = entry.amount; icon = entry.source.icon; iconColor = entry.source.themeColor
    }

    init(from entry: ExpenseEntry) {
        id = entry.id; title = entry.title
        subtitle = entry.note.isEmpty ? nil : entry.note
        amount = entry.amount; icon = entry.category.icon; iconColor = entry.category.color
    }
}

private struct TransactionRow: View {
    let item: TransactionItem
    let amountColor: Color
    let sign: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(item.iconColor.opacity(0.12))
                    .frame(width: 38, height: 38)
                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(item.iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                if let sub = item.subtitle {
                    Text(sub).font(.system(size: 11)).foregroundStyle(AppTheme.textTertiary).lineLimit(1)
                }
            }
            Spacer()
            Text("\(sign)\(CurrencyFormatter.formatCompact(item.amount))")
                .font(.system(size: 14, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(amountColor)
        }
        .padding(.vertical, 12)
    }
}
