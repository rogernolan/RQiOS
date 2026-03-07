import SwiftUI

struct EquipmentEditorView: View {
    @Bindable var item: CharacterEquipmentItem
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name
        case encumbrance
        case notes
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                editorField(title: "Name") {
                    TextField("Name", text: $item.name)
                        .focused($focusedField, equals: .name)
                }

                editorField(title: "ENC") {
                    TextField("0", value: encumbranceBinding, format: .number)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .encumbrance)
                }

                editorField(title: "Description / Notes") {
                    TextEditor(text: $item.notes)
                        .focused($focusedField, equals: .notes)
                        .frame(minHeight: 132)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground).opacity(0.34), in: RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(item.name.isEmpty ? "New Item" : item.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var encumbranceBinding: Binding<Int> {
        Binding(
            get: { item.encumbrance },
            set: { item.encumbrance = max(0, $0) }
        )
    }

    private func editorField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            content()
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.quaternary, lineWidth: 1)
                }
        }
    }
}
