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
        allIncome.filter { $0.month == currentMonth && $0.year == currentYear }.reduce(0) { $0 + $1.amount }
    }

    private var monthlyExpenses: Double {
        allExpenses.filter { $0.month == currentMonth && $0.year == currentYear }.reduce(0) { $0 + $1.amount }
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

    private var recentExpenses: [ExpenseEntry] {
        allExpenses
            .filter { $0.month == currentMonth && $0.year == currentYear }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(4).map { $0 }
    }

    private var snapshotHistory: [Double] {
        snapshots.sorted { $0.snapshotDate < $1.snapshotDate }.map(\.netWorth)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.sectionSpacing) {
                greetingHeader
                heroCard
                statGrid
                healthCard
                if !recentExpenses.isEmpty { recentCard }
                insightCard
            }
            .padding(.horizontal, AppTheme.cardPadding)
            .padding(.top, 56)
        }
        .background(appBackground)
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 90) }
    }

    // MARK: - Background with subtle mint glow
    private var appBackground: some View {
        ZStack {
            AppTheme.background
            RadialGradient(
                colors: [AppTheme.mint.opacity(0.06), .clear],
                center: .top, startRadius: 0, endRadius: 300
            )
        }
        .ignoresSafeArea()
    }

    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }

    // MARK: - Greeting header
    private var greetingHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Date().formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.08 * 11)
                    .textCase(.uppercase)
                    .foregroundStyle(AppTheme.textTertiary)
                Text(timeOfDayGreeting)
                    .font(.system(size: 28, weight: .bold))
                    .tracking(-0.02 * 28)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            Spacer()
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(AppTheme.surface)
                        .frame(width: 38, height: 38)
                        .overlay(RoundedRectangle(cornerRadius: 11).stroke(AppTheme.hairline, lineWidth: 0.5))
                    Image(systemName: "bell")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                ZStack {
                    Circle()
                        .fill(AppTheme.surface3)
                        .frame(width: 38, height: 38)
                    Text("N")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppTheme.mint)
                }
                .overlay(Circle().stroke(AppTheme.hairline2, lineWidth: 0.5))
            }
        }
    }

    // MARK: - Hero net worth card
    private var heroCard: some View {
        VStack(spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("NET WORTH")
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(11 * 0.08)
                        .foregroundStyle(AppTheme.textTertiary)
                    Text(CurrencyFormatter.format(netWorth))
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.textPrimary)
                        .contentTransition(.numericText(value: netWorth))
                        .animation(.spring(duration: 0.4), value: netWorth)

                    if let prev = previousNetWorth {
                        DeltaChip(delta: netWorth - prev)
                    }
                }
                Spacer()
                if snapshotHistory.count >= 2 {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("12-mo")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AppTheme.textTertiary)
                        SparkAreaChart(data: snapshotHistory, color: AppTheme.mint)
                            .frame(width: 120, height: 48)
                    }
                }
            }

            // Asset / liability split bar
            VStack(spacing: 10) {
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        let total = totalAssets + totalLiabilities
                        let assetFrac = total > 0 ? totalAssets / total : 0.5
                        RoundedRectangle(cornerRadius: 999)
                            .fill(AppTheme.mint)
                            .frame(width: geo.size.width * CGFloat(assetFrac))
                        RoundedRectangle(cornerRadius: 999)
                            .fill(AppTheme.coral)
                    }
                }
                .frame(height: 6)
                .clipShape(Capsule())

                HStack {
                    HStack(spacing: 6) {
                        Circle().fill(AppTheme.mint).frame(width: 8, height: 8)
                        Text("Assets")
                            .font(.system(size: 12)).foregroundStyle(AppTheme.textTertiary)
                        Text(CurrencyFormatter.formatCompact(totalAssets))
                            .font(.system(size: 12, weight: .semibold)).monospacedDigit()
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Circle().fill(AppTheme.coral).frame(width: 8, height: 8)
                        Text("Liabilities")
                            .font(.system(size: 12)).foregroundStyle(AppTheme.textTertiary)
                        Text(CurrencyFormatter.formatCompact(totalLiabilities))
                            .font(.system(size: 12, weight: .semibold)).monospacedDigit()
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .darkCard()
    }

    // MARK: - 2x2 stat grid
    private var statGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            MiniStatWidget(icon: "arrow.down.circle", label: "Income",    value: CurrencyFormatter.formatCompact(monthlyIncome),   sub: "this month",                          accentColor: AppTheme.mint)
            MiniStatWidget(icon: "arrow.up.circle",   label: "Expenses",  value: CurrencyFormatter.formatCompact(monthlyExpenses), sub: "this month",                          accentColor: AppTheme.coral)
            MiniStatWidget(icon: "sparkles",           label: "Saved",     value: CurrencyFormatter.formatCompact(max(savings, 0)), sub: "\(Int(savingsRate * 100))% rate",     accentColor: AppTheme.violet)
            MiniStatWidget(icon: "chart.line.uptrend.xyaxis", label: "Save Rate", value: "\(Int(savingsRate * 100))%",             sub: "target >20%",                         accentColor: AppTheme.cyan)
        }
    }

    // MARK: - Financial health card
    private var healthCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("FINANCIAL HEALTH")
                    .font(.system(size: 12, weight: .heavy))
                    .tracking(12 * 0.08)
                    .foregroundStyle(AppTheme.textTertiary)
                Spacer()
                Text(healthLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.mint)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(AppTheme.mint.opacity(0.12), in: Capsule())
            }

            HStack(spacing: 18) {
                CircularProgressRing(
                    progress: Double(healthScore) / 100,
                    gradient: AppTheme.mintVioletGradient,
                    lineWidth: 11, size: 108,
                    label: "\(healthScore)", sublabel: "/100"
                )

                VStack(alignment: .leading, spacing: 10) {
                    healthPillar(label: "Savings rate",   value: "\(Int(savingsRate * 100))%",  target: ">20%", met: savingsRate >= 0.20)
                    healthPillar(label: "Debt-to-asset",  value: totalAssets > 0 ? "\(Int(min(totalLiabilities / totalAssets, 1) * 100))%" : "—", target: "<40%", met: totalAssets > 0 && totalLiabilities / totalAssets < 0.4)
                    healthPillar(label: "Positive NW",    value: netWorth >= 0 ? "Yes" : "No",  target: ">0",   met: netWorth >= 0)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .darkCard()
    }

    @ViewBuilder
    private func healthPillar(label: String, value: String, target: String, met: Bool) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(met ? AppTheme.mint.opacity(0.15) : AppTheme.coral.opacity(0.15))
                    .frame(width: 18, height: 18)
                Image(systemName: met ? "checkmark" : "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(met ? AppTheme.mint : AppTheme.coral)
            }
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(AppTheme.textPrimary)
            Text(target)
                .font(.system(size: 10))
                .foregroundStyle(AppTheme.textQuaternary)
                .frame(width: 34, alignment: .trailing)
        }
    }

    // MARK: - Recent activity
    private var recentCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("RECENT ACTIVITY")
                    .font(.system(size: 12, weight: .heavy))
                    .tracking(12 * 0.08)
                    .foregroundStyle(AppTheme.textTertiary)
                Spacer()
                Text("See all")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.mint)
            }
            VStack(spacing: 0) {
                ForEach(recentExpenses) { expense in
                    txnRow(expense: expense)
                    if expense.id != recentExpenses.last?.id {
                        Divider()
                            .background(AppTheme.hairline)
                            .padding(.leading, 62)
                    }
                }
            }
            .darkCard()
        }
    }

    @ViewBuilder
    private func txnRow(expense: ExpenseEntry) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(expense.category.color.opacity(0.12))
                    .frame(width: 38, height: 38)
                Image(systemName: expense.category.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(expense.category.color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                Text("\(expense.category.rawValue)")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            Spacer()
            Text("−\(CurrencyFormatter.formatCompact(expense.amount))")
                .font(.system(size: 14, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(AppTheme.coral)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    // MARK: - Insight card
    private var insightCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.mint.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.mint)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("INSIGHT")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(11 * 0.06)
                    .foregroundStyle(AppTheme.mint)
                Text(insightText)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(AppTheme.cardPadding)
        .darkCard()
    }

    private var insightText: String {
        if savingsRate >= 0.20 {
            return "Great work — you're saving \(Int(savingsRate * 100))% of income this month, above the 20% target."
        } else if monthlyIncome > 0 {
            return "Your savings rate is \(Int(savingsRate * 100))%. Aim for 20% to build wealth faster."
        } else {
            return "Add income and expenses to get personalised insights about your finances."
        }
    }
}
