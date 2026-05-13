import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardTabView()
                .tabItem {
                    Label("Overview", systemImage: "square.grid.2x2.fill")
                }

            BudgetTabView()
                .tabItem {
                    Label("Budget", systemImage: "dollarsign.circle.fill")
                }

            NetWorthTabView()
                .tabItem {
                    Label("Net Worth", systemImage: "chart.pie.fill")
                }

            HistoryTabView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
        .tint(AppTheme.accent)
    }
}
