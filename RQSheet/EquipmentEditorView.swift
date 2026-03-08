import SwiftUI

struct EquipmentEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var encumbranceText: String
    @State private var notes: String

    let title: String
    let onSave: (String, Int, String) -> Void

    init(
        title: String,
        name: String = "",
        encumbrance: Int = 0,
        notes: String = "",
        onSave: @escaping (String, Int, String) -> Void
    ) {
        self.title = title
        self.onSave = onSave
        _name = State(initialValue: name)
        _encumbranceText = State(initialValue: String(max(0, encumbrance)))
        _notes = State(initialValue: notes)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    LabeledContent("Name") {
                        TextField("Name", text: $name)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("ENC") {
                        TextField("0", text: $encumbranceText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Description / Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 180)
                        .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(cleanName, parsedEncumbrance, notes)
                        dismiss()
                    }
                }
            }
        }
    }

    private var cleanName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var parsedEncumbrance: Int {
        max(0, Int(encumbranceText.filter(\.isNumber)) ?? 0)
    }
}
