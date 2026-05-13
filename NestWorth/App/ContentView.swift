import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showAddSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardTabView().tag(0)
                BudgetTabView().tag(1)
                NetWorthTabView().tag(2)
                HistoryTabView().tag(3)
            }
            .toolbar(.hidden, for: .tabBar)
            .ignoresSafeArea(edges: .bottom)

            FloatingTabBar(selectedTab: $selectedTab, onFAB: { showAddSheet = true })
                .padding(.horizontal, 20)
                .padding(.bottom, 22)
        }
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showAddSheet) {
            AddEntrySheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Floating Tab Bar

private struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let onFAB: () -> Void

    private struct TabItem {
        let tag: Int
        let icon: String
        let label: String
    }

    private let leftTabs  = [TabItem(tag: 0, icon: "square.grid.2x2", label: "Overview"),
                              TabItem(tag: 1, icon: "dollarsign.circle", label: "Budget")]
    private let rightTabs = [TabItem(tag: 2, icon: "chart.pie", label: "Net Worth"),
                              TabItem(tag: 3, icon: "clock.arrow.circlepath", label: "History")]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(leftTabs, id: \.tag) { item in
                tabButton(item)
            }

            // Center FAB
            Button(action: onFAB) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppTheme.background)
                    .frame(width: 50, height: 50)
                    .background(AppTheme.mint, in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 8)

            ForEach(rightTabs, id: \.tag) { item in
                tabButton(item)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26))
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(AppTheme.hairline, lineWidth: 0.5))
        .shadow(color: .black.opacity(0.4), radius: 20, y: 8)
    }

    @ViewBuilder
    private func tabButton(_ item: TabItem) -> some View {
        let active = selectedTab == item.tag
        Button { selectedTab = item.tag } label: {
            VStack(spacing: 4) {
                Image(systemName: item.icon)
                    .font(.system(size: 20, weight: active ? .semibold : .regular))
                Text(item.label)
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.2)
            }
            .foregroundStyle(active ? AppTheme.mint : AppTheme.textQuaternary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add Entry Sheet

private struct AddEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAddIncome   = false
    @State private var showAddExpense  = false
    @State private var showAddAsset    = false
    @State private var showAddLiability = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                entryButton(icon: "arrow.down.circle.fill", label: "Add Income",    color: AppTheme.mint)    { showAddIncome    = true }
                entryButton(icon: "arrow.up.circle.fill",   label: "Add Expense",   color: AppTheme.coral)   { showAddExpense   = true }
                entryButton(icon: "building.columns.fill",  label: "Add Asset",     color: AppTheme.violet)  { showAddAsset     = true }
                entryButton(icon: "creditcard.fill",        label: "Add Liability", color: AppTheme.amber)   { showAddLiability = true }
            }
            .padding(20)
            .navigationTitle("Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppTheme.mint)
                }
            }
        }
        .sheet(isPresented: $showAddIncome)    { AddIncomeSheet(month: DateHelpers.currentMonth(), year: DateHelpers.currentYear()) }
        .sheet(isPresented: $showAddExpense)   { AddExpenseSheet(month: DateHelpers.currentMonth(), year: DateHelpers.currentYear()) }
        .sheet(isPresented: $showAddAsset)     { AddAssetSheet() }
        .sheet(isPresented: $showAddLiability) { AddLiabilitySheet() }
    }

    @ViewBuilder
    private func entryButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(color)
                }
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.textQuaternary)
            }
            .padding(16)
            .darkCard()
        }
        .buttonStyle(.plain)
    }
}
