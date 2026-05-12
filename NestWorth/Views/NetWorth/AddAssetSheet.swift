import SwiftUI
import SwiftData

struct AddAssetSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var existing: Asset? = nil

    @State private var name = ""
    @State private var type: AssetType = .savings
    @State private var value = 0.0
    @State private var note = ""

    private var isEditing: Bool { existing != nil }
    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && value > 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name (e.g. Chase Savings)", text: $name)
                        .autocorrectionDisabled()
                }

                Section {
                    CurrencyTextField(label: "Current Value", value: $value)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(AssetType.allCases, id: \.self) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Note (optional)") {
                    TextField("Add a note...", text: $note, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle(isEditing ? "Edit Asset" : "Add Asset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Save") { save() }
                        .disabled(!isValid)
                        .fontWeight(.semibold)
                }
            }
            .onAppear { populateIfEditing() }
        }
    }

    private func populateIfEditing() {
        guard let asset = existing else { return }
        name = asset.name
        type = asset.type
        value = asset.value
        note = asset.note
    }

    private func save() {
        if let asset = existing {
            asset.name = name.trimmingCharacters(in: .whitespaces)
            asset.type = type
            asset.value = value
            asset.note = note
            asset.updatedAt = Date()
        } else {
            let asset = Asset(
                name: name.trimmingCharacters(in: .whitespaces),
                type: type,
                value: value,
                note: note
            )
            modelContext.insert(asset)
        }
        dismiss()
    }
}
