import SwiftUI
import SwiftData

struct AddExpenseSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let month: Int
    let year: Int
    var existing: ExpenseEntry? = nil

    @State private var title = ""
    @State private var amount = 0.0
    @State private var category: ExpenseCategory = .housing
    @State private var note = ""

    private var isEditing: Bool { existing != nil }
    private var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty && amount > 0 }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                RadialGradient(colors: [AppTheme.coral.opacity(0.05), .clear], center: .top, startRadius: 0, endRadius: 280)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 0) {
                            CurrencyTextField(label: "Amount", value: $amount)
                        }
                        .padding(AppTheme.cardPadding)
                        .darkCard()

                        darkField(label: "Title", placeholder: "e.g. Monthly Rent", text: $title)

                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Category")
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(ExpenseCategory.allCases, id: \.self) { c in
                                    categoryChip(c)
                                }
                            }
                        }
                        .padding(AppTheme.cardPadding)
                        .darkCard()

                        HStack {
                            sectionLabel("Period")
                            Spacer()
                            Text(DateHelpers.displayString(month: month, year: year))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .padding(AppTheme.cardPadding)
                        .darkCard()

                        darkField(label: "Note (optional)", placeholder: "Add a note...", text: $note, axis: .vertical)
                    }
                    .padding(.horizontal, AppTheme.cardPadding)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(isEditing ? "Edit Expense" : "Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.textTertiary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Save") { save() }
                        .disabled(!isValid)
                        .fontWeight(.semibold)
                        .foregroundStyle(isValid ? AppTheme.mint : AppTheme.textQuaternary)
                }
            }
            .onAppear { populateIfEditing() }
        }
    }

    @ViewBuilder
    private func categoryChip(_ c: ExpenseCategory) -> some View {
        let selected = category == c
        Button { category = c } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selected ? c.color : c.color.opacity(0.10))
                        .frame(width: 36, height: 36)
                    Image(systemName: c.icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(selected ? AppTheme.background : c.color)
                }
                Text(c.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(selected ? AppTheme.textPrimary : AppTheme.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(selected ? AppTheme.surface2 : AppTheme.surface3, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? c.color.opacity(0.5) : AppTheme.hairline, lineWidth: selected ? 1 : 0.5)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.25), value: selected)
    }

    @ViewBuilder
    private func darkField(label: String, placeholder: String, text: Binding<String>, axis: Axis = .horizontal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel(label)
            TextField(placeholder, text: text, axis: axis)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(axis == .vertical ? 3...6 : 1...1)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AppTheme.surface2, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.hairline2, lineWidth: 0.5))
        }
        .padding(AppTheme.cardPadding)
        .darkCard()
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .heavy))
            .tracking(11 * 0.08)
            .textCase(.uppercase)
            .foregroundStyle(AppTheme.textTertiary)
    }

    private func populateIfEditing() {
        guard let entry = existing else { return }
        title = entry.title
        amount = entry.amount
        category = entry.category
        note = entry.note
    }

    private func save() {
        if let entry = existing {
            entry.title = title.trimmingCharacters(in: .whitespaces)
            entry.amount = amount
            entry.category = category
            entry.note = note
        } else {
            let entry = ExpenseEntry(
                title: title.trimmingCharacters(in: .whitespaces),
                amount: amount,
                category: category,
                month: month,
                year: year,
                note: note
            )
            modelContext.insert(entry)
        }
        dismiss()
    }
}
