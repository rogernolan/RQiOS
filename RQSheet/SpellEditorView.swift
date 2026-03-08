import SwiftUI

struct SpellEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var pointsText: String
    @State private var page: String

    let title: String
    let onSave: (String, Int, String) -> Void

    init(
        title: String,
        name: String = "",
        points: Int = 0,
        page: String = "",
        onSave: @escaping (String, Int, String) -> Void
    ) {
        self.title = title
        self.onSave = onSave
        _name = State(initialValue: name)
        _pointsText = State(initialValue: String(max(0, points)))
        _page = State(initialValue: page)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    LabeledContent("Name") {
                        TextField("Name", text: $name)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Points") {
                        TextField("0", text: $pointsText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Page") {
                        TextField("Page", text: $page)
                            .multilineTextAlignment(.trailing)
                    }
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
                        onSave(cleanName, parsedPoints, cleanPage)
                        dismiss()
                    }
                }
            }
        }
    }

    private var cleanName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanPage: String {
        page.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var parsedPoints: Int {
        max(0, Int(pointsText.filter(\.isNumber)) ?? 0)
    }
}
