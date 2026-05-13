# NestWorth — Claude Code Guide

## Project
iOS 17+ SwiftUI app for personal finance: net worth tracking and budget management.
Built with SwiftData for persistence, Swift Charts for visualisation, XcodeGen for project generation.

## Key commands

```bash
# Regenerate .xcodeproj after editing project.yml
xcodegen generate

# Run tests from CLI (requires Xcode command-line tools)
xcodebuild test -scheme NestWorth -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture
- `NestWorth/Models/` — SwiftData `@Model` classes (Asset, Liability, IncomeEntry, ExpenseEntry, NetWorthSnapshot)
- `NestWorth/Models/Enums/` — enums for types/categories (all `Codable + CaseIterable`)
- `NestWorth/ViewModels/` — `@Observable` view models containing business logic (BudgetViewModel, NetWorthViewModel)
- `NestWorth/Views/` — SwiftUI views grouped by feature (Budget, NetWorth, History, Charts, Shared)
- `NestWorth/DesignSystem/` — AppTheme tokens and enum theme extensions
- `NestWorth/Utilities/` — pure-function helpers (CurrencyFormatter, DateHelpers)
- `NestWorthTests/` — Swift Testing framework unit tests

## Conventions
- Use `@Observable` (not `ObservableObject`) — deployment target is iOS 17
- ViewModels receive model arrays as parameters; they do not hold SwiftData queries directly
- `NetWorthSnapshot.netWorth` is a computed property — never store it separately
- Tests use `ModelConfiguration(isStoredInMemoryOnly: true)` for SwiftData tests
- Use Swift Testing (`import Testing`, `#expect`, `@Test`) not XCTest

## project.yml
XcodeGen spec at repo root. Always run `xcodegen generate` after modifying it.
