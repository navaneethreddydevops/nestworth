import SwiftUI
import SwiftData

struct AddIncomeSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let month: Int
    let year: Int
    var existing: IncomeEntry? = nil

    @State private var title = ""
    @State private var amount = 0.0
    @State private var source: IncomeSource = .salary
    @State private var note = ""

    private var isEditing: Bool { existing != nil }
    private var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty && amount > 0 }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                RadialGradient(colors: [AppTheme.mint.opacity(0.06), .clear], center: .top, startRadius: 0, endRadius: 280)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 0) {
                            CurrencyTextField(label: "Amount", value: $amount)
                        }
                        .padding(AppTheme.cardPadding)
                        .darkCard()

                        darkField(label: "Title", placeholder: "e.g. Monthly Salary", text: $title)

                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Source")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(IncomeSource.allCases, id: \.self) { s in
                                        sourceChip(s)
                                    }
                                }
                                .padding(.horizontal, 1)
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
            .navigationTitle(isEditing ? "Edit Income" : "Add Income")
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
    private func sourceChip(_ s: IncomeSource) -> some View {
        let selected = source == s
        Button { source = s } label: {
            HStack(spacing: 6) {
                Image(systemName: s.icon)
                    .font(.system(size: 13, weight: .medium))
                Text(s.rawValue)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(selected ? AppTheme.background : AppTheme.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(selected ? AppTheme.mint : AppTheme.surface2, in: Capsule())
            .overlay(Capsule().stroke(selected ? AppTheme.mint : AppTheme.hairline, lineWidth: 0.5))
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
        source = entry.source
        note = entry.note
    }

    private func save() {
        if let entry = existing {
            entry.title = title.trimmingCharacters(in: .whitespaces)
            entry.amount = amount
            entry.source = source
            entry.note = note
        } else {
            let entry = IncomeEntry(
                title: title.trimmingCharacters(in: .whitespaces),
                amount: amount,
                source: source,
                month: month,
                year: year,
                note: note
            )
            modelContext.insert(entry)
        }
        dismiss()
    }
}
