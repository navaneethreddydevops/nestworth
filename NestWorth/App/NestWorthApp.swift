import SwiftUI
import SwiftData

@main
struct NestWorthApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            IncomeEntry.self,
            ExpenseEntry.self,
            Asset.self,
            Liability.self,
            NetWorthSnapshot.self
        ])
    }
}
