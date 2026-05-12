import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
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
    }
}
