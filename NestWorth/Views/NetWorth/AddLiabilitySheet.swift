import SwiftUI
import SwiftData

struct AddLiabilitySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var existing: Liability? = nil

    @State private var name = ""
    @State private var type: LiabilityType = .creditCard
    @State private var balance = 0.0
    @State private var note = ""

    private var isEditing: Bool { existing != nil }
    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && balance > 0 }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                RadialGradient(colors: [AppTheme.coral.opacity(0.05), .clear], center: .top, startRadius: 0, endRadius: 280)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 0) {
                            CurrencyTextField(label: "Outstanding Balance", value: $balance)
                        }
                        .padding(AppTheme.cardPadding)
                        .darkCard()

                        darkField(label: "Name", placeholder: "e.g. Chase Sapphire Card", text: $name)

                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Liability Type")
                            VStack(spacing: 8) {
                                ForEach(LiabilityType.allCases, id: \.self) { t in
                                    liabilityTypeRow(t)
                                }
                            }
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
            .navigationTitle(isEditing ? "Edit Liability" : "Add Liability")
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
    private func liabilityTypeRow(_ t: LiabilityType) -> some View {
        let selected = type == t
        Button { type = t } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selected ? AppTheme.coral : AppTheme.coral.opacity(0.10))
                        .frame(width: 36, height: 36)
                    Image(systemName: t.icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(selected ? AppTheme.background : AppTheme.coral)
                }
                Text(t.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(selected ? AppTheme.textPrimary : AppTheme.textSecondary)
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.coral)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(selected ? AppTheme.surface2 : AppTheme.surface3, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? AppTheme.coral.opacity(0.4) : AppTheme.hairline, lineWidth: selected ? 1 : 0.5)
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
        guard let liability = existing else { return }
        name = liability.name
        type = liability.type
        balance = liability.balance
        note = liability.note
    }

    private func save() {
        if let liability = existing {
            liability.name = name.trimmingCharacters(in: .whitespaces)
            liability.type = type
            liability.balance = balance
            liability.note = note
            liability.updatedAt = Date()
        } else {
            let liability = Liability(
                name: name.trimmingCharacters(in: .whitespaces),
                type: type,
                balance: balance,
                note: note
            )
            modelContext.insert(liability)
        }
        dismiss()
    }
}
