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

    private struct MerchantGroup: Identifiable {
        let id = UUID()
        let title: String
        let amount: Double
        let count: Int
    }

    private var merchantGroups: [MerchantGroup] {
        let grouped = Dictionary(grouping: expenses, by: { $0.title })
        return grouped.map { key, entries in
            MerchantGroup(
                title: key,
                amount: entries.reduce(0) { $0 + $1.amount },
                count: entries.count
            )
        }.sorted { $0.amount > $1.amount }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: AppTheme.sectionSpacing) {
                        iconHeader
                        statsRow
                        if merchantGroups.count > 1 { merchantsCard }
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

    // MARK: - Merchant bar chart card
    private var merchantsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("TOP MERCHANTS")
                    .font(.system(size: 12, weight: .heavy)).tracking(12 * 0.08)
                    .foregroundStyle(AppTheme.textTertiary)
                Spacer()
                Text("\(merchantGroups.count) stores")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.textTertiary)
            }

            let maxAmt = merchantGroups.first?.amount ?? 1

            VStack(spacing: 14) {
                ForEach(Array(merchantGroups.prefix(5).enumerated()), id: \.element.id) { i, group in
                    merchantBar(group, maxAmt: maxAmt, rank: i)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .darkCard()
    }

    @ViewBuilder
    private func merchantBar(_ group: MerchantGroup, maxAmt: Double, rank: Int) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(rank == 0 ? category.color.opacity(0.18) : AppTheme.surface3)
                        .frame(width: 30, height: 30)
                    Image(systemName: category.icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(rank == 0 ? category.color : AppTheme.textTertiary)
                }

                Text(group.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                Spacer()

                VStack(alignment: .trailing, spacing: 1) {
                    Text(CurrencyFormatter.formatCompact(group.amount))
                        .font(.system(size: 13, weight: .bold)).monospacedDigit()
                        .foregroundStyle(AppTheme.textPrimary)
                    if group.count > 1 {
                        Text("\(group.count) txns")
                            .font(.system(size: 10))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.surface3)
                        .frame(height: 5)
                    Capsule()
                        .fill(category.color.opacity(rank == 0 ? 0.85 : 0.45))
                        .frame(width: max(0, geo.size.width * CGFloat(group.amount / maxAmt)), height: 5)
                        .animation(.spring(duration: 0.5, bounce: 0.2), value: group.amount)
                }
            }
            .frame(height: 5)
        }
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
