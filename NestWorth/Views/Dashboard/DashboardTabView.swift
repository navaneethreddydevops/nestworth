import SwiftUI
import SwiftData

struct DashboardTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var assets:      [Asset]
    @Query private var liabilities: [Liability]
    @Query(sort: \NetWorthSnapshot.snapshotDate, order: .reverse)
    private var snapshots: [NetWorthSnapshot]
    @Query private var allIncome:   [IncomeEntry]
    @Query private var allExpenses: [ExpenseEntry]

    private var totalAssets:      Double { assets.reduce(0)      { $0 + $1.value } }
    private var totalLiabilities: Double { liabilities.reduce(0) { $0 + $1.balance } }
    private var netWorth:         Double { totalAssets - totalLiabilities }
    private var previousNetWorth: Double? { snapshots.first?.netWorth }

    private var currentMonth: Int { DateHelpers.currentMonth() }
    private var currentYear:  Int { DateHelpers.currentYear() }

    private var monthlyIncome: Double {
        allIncome
            .filter { $0.month == currentMonth && $0.year == currentYear }
            .reduce(0) { $0 + $1.amount }
    }

    private var monthlyExpenses: Double {
        allExpenses
            .filter { $0.month == currentMonth && $0.year == currentYear }
            .reduce(0) { $0 + $1.amount }
    }

    private var savings: Double { monthlyIncome - monthlyExpenses }
    private var savingsRate: Double { monthlyIncome > 0 ? max(0, savings / monthlyIncome) : 0 }

    private var healthScore: Int {
        var score = 0
        if savingsRate >= 0.20 { score += 35 }
        else if savingsRate > 0 { score += Int(savingsRate / 0.20 * 35) }
        if netWorth > 0 { score += 35 }
        if totalLiabilities == 0 || (totalAssets > 0 && totalLiabilities / totalAssets < 0.4) { score += 30 }
        return min(score, 100)
    }

    private var healthLabel: String {
        switch healthScore {
        case 80...100: return "Excellent"
        case 60...79:  return "Good"
        case 40...59:  return "Fair"
        default:       return "Needs Work"
        }
    }

    private var healthColor: Color {
        switch healthScore {
        case 80...100: return AppTheme.income
        case 60...79:  return AppTheme.teal
        case 40...59:  return AppTheme.warning
        default:       return AppTheme.expense
        }
    }

    private var recentExpenses: [ExpenseEntry] {
        allExpenses
            .filter { $0.month == currentMonth && $0.year == currentYear }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(4)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.sectionSpacing) {

                    // Hero net worth card
                    netWorthHeroCard

                    // 2x2 stat grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MiniStatWidget(
                            icon: "arrow.down.circle.fill",
                            label: "This Month Income",
                            value: CurrencyFormatter.formatCompact(monthlyIncome),
                            gradient: AppTheme.incomeGradient,
                            valueColor: AppTheme.income
                        )
                        MiniStatWidget(
                            icon: "arrow.up.circle.fill",
                            label: "This Month Expenses",
                            value: CurrencyFormatter.formatCompact(monthlyExpenses),
                            gradient: AppTheme.expenseGradient,
                            valueColor: AppTheme.expense
                        )
                        MiniStatWidget(
                            icon: "building.columns.fill",
                            label: "Total Assets",
                            value: CurrencyFormatter.formatCompact(totalAssets),
                            gradient: AppTheme.accentGradient,
                            valueColor: AppTheme.accent
                        )
                        MiniStatWidget(
                            icon: "creditcard.fill",
                            label: "Total Liabilities",
                            value: CurrencyFormatter.formatCompact(totalLiabilities),
                            gradient: AppTheme.purpleGradient,
                            valueColor: AppTheme.purple
                        )
                    }

                    // Financial health card
                    financialHealthCard

                    // Savings progress card
                    if monthlyIncome > 0 {
                        savingsProgressCard
                    }

                    // Recent spending
                    if !recentExpenses.isEmpty {
                        recentSpendingCard
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, AppTheme.cardPadding)
                .padding(.top, 8)
            }
            .background(AppTheme.background)
            .navigationTitle("Overview")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Sub-views

    private var netWorthHeroCard: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Net Worth")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.75))
                        Text(CurrencyFormatter.format(netWorth))
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText(value: netWorth))
                            .animation(.spring(duration: 0.4), value: netWorth)
                    }
                    Spacer()
                    // Mini ring showing liabilities ratio
                    VStack(spacing: 4) {
                        CircularProgressRing(
                            progress: totalAssets > 0 ? min(netWorth / totalAssets, 1) : 0,
                            gradient: LinearGradient(
                                colors: [.white.opacity(0.9), .white.opacity(0.5)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 7,
                            size: 62
                        )
                        Text("Equity")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.65))
                    }
                }

                if let prev = previousNetWorth {
                    let delta = netWorth - prev
                    deltaBadge(delta)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(AppTheme.cardPadding)
            .gradientCard(netWorth >= 0 ? AppTheme.netWorthGradient : AppTheme.expenseGradient)
        }
    }

    @ViewBuilder
    private func deltaBadge(_ delta: Double) -> some View {
        let positive = delta >= 0
        let color: Color = delta == 0 ? .white.opacity(0.6) : (positive ? Color(red: 0.6, green: 1, blue: 0.75) : Color(red: 1, green: 0.6, blue: 0.6))
        let icon = delta == 0 ? "minus" : (positive ? "arrow.up.right" : "arrow.down.right")
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2.weight(.bold))
            Text("\(positive ? "+" : "")\(CurrencyFormatter.formatCompact(delta)) from last snapshot")
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.white.opacity(0.15), in: Capsule())
    }

    private var financialHealthCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Financial Health")
                .font(.headline)
                .foregroundStyle(.primary)

            HStack(spacing: 20) {
                CircularProgressRing(
                    progress: Double(healthScore) / 100.0,
                    gradient: LinearGradient(
                        colors: [healthColor, healthColor.opacity(0.6)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 9,
                    size: 86,
                    label: "\(healthScore)",
                    sublabel: "/100"
                )

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Circle().fill(healthColor).frame(width: 8, height: 8)
                        Text(healthLabel)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(healthColor)
                    }

                    healthPillar(
                        icon: "arrow.up.arrow.down",
                        label: "Savings Rate",
                        value: "\(Int(savingsRate * 100))%",
                        met: savingsRate >= 0.15
                    )
                    healthPillar(
                        icon: "scalemass",
                        label: "Positive Net Worth",
                        value: netWorth >= 0 ? "Yes" : "No",
                        met: netWorth >= 0
                    )
                    healthPillar(
                        icon: "creditcard",
                        label: "Low Debt Ratio",
                        value: totalAssets > 0 ? "\(Int(min(totalLiabilities / totalAssets, 1) * 100))%" : "—",
                        met: totalAssets > 0 && totalLiabilities / totalAssets < 0.4
                    )
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .glassBackground()
    }

    @ViewBuilder
    private func healthPillar(icon: String, label: String, value: String, met: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.caption)
                .foregroundStyle(met ? AppTheme.income : AppTheme.expense)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }

    private var savingsProgressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Monthly Savings")
                    .font(.headline)
                Spacer()
                Text(CurrencyFormatter.formatCompact(max(savings, 0)))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(savings >= 0 ? AppTheme.income : AppTheme.expense)
            }

            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6).fill(Color(uiColor: .systemFill)).frame(height: 10)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(savingsRate >= 0.2 ? AppTheme.incomeGradient : AppTheme.warningGradient)
                            .frame(width: max(4, geo.size.width * CGFloat(savingsRate)), height: 10)
                            .animation(.spring(duration: 0.6), value: savingsRate)
                    }
                }
                .frame(height: 10)

                HStack {
                    Text("Savings rate: \(Int(savingsRate * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Target: 20%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Income vs Expenses mini bar
            HStack(spacing: 6) {
                barSegment(label: "Income", value: monthlyIncome, total: max(monthlyIncome, monthlyExpenses), color: AppTheme.income)
                barSegment(label: "Expenses", value: monthlyExpenses, total: max(monthlyIncome, monthlyExpenses), color: AppTheme.expense)
            }
        }
        .padding(AppTheme.cardPadding)
        .glassBackground()
    }

    @ViewBuilder
    private func barSegment(label: String, value: Double, total: Double, color: Color) -> some View {
        let ratio = total > 0 ? value / total : 0
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(color.opacity(0.15)).frame(height: 8)
                    RoundedRectangle(cornerRadius: 4).fill(color).frame(width: geo.size.width * CGFloat(ratio), height: 8)
                        .animation(.spring(duration: 0.5), value: ratio)
                }
            }
            .frame(height: 8)
            HStack {
                Circle().fill(color).frame(width: 6, height: 6)
                Text(label).font(.caption2).foregroundStyle(.secondary)
                Spacer()
                Text(CurrencyFormatter.formatCompact(value)).font(.caption2.weight(.semibold)).foregroundStyle(color)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var recentSpendingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Spending")
                .font(.headline)
                .padding(.horizontal, 2)

            VStack(spacing: 0) {
                ForEach(recentExpenses) { expense in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(expense.category.color.opacity(0.15))
                                .frame(width: 38, height: 38)
                            Image(systemName: expense.category.icon)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(expense.category.color)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(expense.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text(expense.category.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(CurrencyFormatter.formatCompact(expense.amount))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.expense)
                    }
                    .padding(.vertical, 10)
                    if expense.id != recentExpenses.last?.id {
                        Divider().padding(.leading, 50)
                    }
                }
            }
            .padding(AppTheme.cardPadding)
            .glassBackground()
        }
    }
}
