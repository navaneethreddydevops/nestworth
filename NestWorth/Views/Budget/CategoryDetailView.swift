import SwiftUI

struct CategoryDetailView: View {
    let category: ExpenseCategory
    let expenses: [ExpenseEntry]
    let month: Int
    let year: Int

    @Environment(\.dismiss) private var dismiss

    private var total: Double { expenses.reduce(0) { $0 + $1.amount } }
    private var average: Double { expenses.isEmpty ? 0 : total / Double(expenses.count) }
    private var sorted: [ExpenseEntry] { expenses.sorted { $0.createdAt > $1.createdAt } }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: AppTheme.sectionSpacing) {
                        iconHeader
                        statsRow
                        if !sorted.isEmpty { transactionList }
                    }
                    .padding(.horizontal, AppTheme.cardPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppTheme.mint)
                }
            }
        }
    }

    // MARK: - Icon header
    private var iconHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(category.color.opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: category.icon)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(category.color)
            }
            VStack(spacing: 4) {
                Text(category.rawValue)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(DateHelpers.displayString(month: month, year: year))
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            Text(CurrencyFormatter.format(total))
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Mini stats row
    private var statsRow: some View {
        HStack(spacing: 1) {
            statCell(label: "Total", value: CurrencyFormatter.formatCompact(total), color: category.color)
            Divider().frame(height: 36).background(AppTheme.hairline)
            statCell(label: "Avg / txn", value: CurrencyFormatter.formatCompact(average), color: AppTheme.textSecondary)
            Divider().frame(height: 36).background(AppTheme.hairline)
            statCell(label: "Transactions", value: "\(expenses.count)", color: AppTheme.textSecondary)
        }
        .padding(.vertical, 14)
        .darkCard()
    }

    @ViewBuilder
    private func statCell(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Transaction list
    private var transactionList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TRANSACTIONS · \(sorted.count)")
                .font(.system(size: 12, weight: .heavy)).tracking(12 * 0.08)
                .foregroundStyle(AppTheme.textTertiary)

            VStack(spacing: 0) {
                ForEach(sorted) { entry in
                    categoryTransactionRow(entry: entry)
                    if entry.id != sorted.last?.id {
                        Divider().background(AppTheme.hairline).padding(.leading, 62)
                    }
                }
            }
            .darkCard()
        }
    }

    @ViewBuilder
    private func categoryTransactionRow(entry: ExpenseEntry) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(category.color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(category.color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.textTertiary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Text("−\(CurrencyFormatter.formatCompact(entry.amount))")
                .font(.system(size: 14, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(AppTheme.coral)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
