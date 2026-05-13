# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This project uses **XcodeGen** (`project.yml`) to generate the `.xcodeproj`. If you modify `project.yml`, regenerate the project:

```bash
xcodegen generate
```

Build from the command line (requires Xcode):

```bash
xcodebuild -project NestWorth.xcodeproj -scheme NestWorth -destination 'platform=iOS Simulator,name=iPhone 15' build
```

No test target currently exists — run and test via Xcode Simulator.

## Architecture

**SwiftUI + SwiftData**, iOS 17+ only. No third-party dependencies.

- **`App/`** — Entry point. `NestWorthApp` sets up the `ModelContainer` for all five SwiftData models. `ContentView` is a 3-tab shell (Budget, Net Worth, History).
- **`Models/`** — SwiftData `@Model` classes: `Asset`, `Liability`, `IncomeEntry`, `ExpenseEntry`, `NetWorthSnapshot`. Enums live in `Models/Enums/`.
- **`Views/`** — Organized by tab: `Budget/`, `NetWorth/`, `History/`. `Shared/` holds reusable components (`GlassCard`, `CurrencyTextField`, `AnimatedCurrencyText`, `EmptyStateView`, `MonthYearPicker`). `Charts/` holds Swift Charts wrappers.
- **`DesignSystem/`** — `AppTheme` is the single source of truth for colors, gradients, corner radii, spacing, and view modifier extensions (`.glassBackground()`, `.surfaceBackground()`).
- **`Utilities/`** — `CurrencyFormatter` and `DateHelpers`.

## Key Conventions

- All colors and layout constants come from `AppTheme` — never use hardcoded colors or magic numbers.
- `AppTheme.assetColors` maps to `AssetType` cases in order; keep them in sync when adding asset types.
- SwiftData models are injected via the environment — views query with `@Query` and mutate via `modelContext`.
- The project targets iOS 17 and Swift 5.9; use only APIs available on that baseline.
