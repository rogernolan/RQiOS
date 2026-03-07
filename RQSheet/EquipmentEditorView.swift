import SwiftUI

struct EquipmentEditorView: View {
    @Bindable var item: CharacterEquipmentItem

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $item.name)
            } header: {
                Text("Name")
            }

            Section {
                TextField("ENC", value: encumbranceBinding, format: .number)
                    .keyboardType(.numberPad)
            } header: {
                Text("ENC")
            }

            Section {
                TextField("Description / Notes", text: $item.notes, axis: .vertical)
                    .lineLimit(4, reservesSpace: true)
            } header: {
                Text("Description / Notes")
            }
        }
        .navigationTitle(item.name.isEmpty ? "New Item" : item.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var encumbranceBinding: Binding<Int> {
        Binding(
            get: { item.encumbrance },
            set: { item.encumbrance = max(0, $0) }
        )
    }
}
