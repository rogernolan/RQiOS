import SwiftData
import SwiftUI

struct EquipmentView: View {
    @Query private var characters: [RQCharacter]

    private var character: RQCharacter? {
        characters.first
    }

    var body: some View {
        Group {
            if let character {
                CharacterEquipmentContentView(character: character)
            } else {
                Text("Create a character in Summary to manage equipment.")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .mainRuneBackground(runeName: "RuneTrade")
    }
}

private struct CharacterEquipmentContentView: View {
    @Environment(\.modelContext) private var modelContext

    let character: RQCharacter

    @State private var viewModel: EquipmentViewModel
    @State private var presentedEditor: EquipmentEditorSheet?

    init(character: RQCharacter) {
        self.character = character
        _viewModel = State(initialValue: EquipmentViewModel(character: character))
    }

    var body: some View {
        ZStack(alignment: .top) {
            equipmentList
            headerOverlay
        }
        .sheet(item: $presentedEditor) { editor in
            EquipmentEditorView(
                title: editor.title,
                name: editor.name,
                encumbrance: editor.encumbrance,
                notes: editor.notes
            ) { name, encumbrance, notes in
                if let item = editor.item {
                    viewModel.updateItem(item, name: name, encumbrance: encumbrance, notes: notes)
                } else {
                    viewModel.addNewItem(name: name, encumbrance: encumbrance, notes: notes)
                }
            }
        }
        .alert("This cannot be undone", isPresented: isShowingDeleteAlert) {
            Button("No", role: .cancel) {
                viewModel.cancelDelete()
            }
            Button("Yes", role: .destructive) {
                if let pending = viewModel.pendingDeleteItem {
                    modelContext.delete(pending)
                }
                viewModel.confirmDelete()
            }
        } message: {
            Text("Delete this equipment item?")
        }
    }

    private var equipmentList: some View {
        List {
            Color.clear
                .frame(height: 92)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            if viewModel.visibleItems.isEmpty {
                Text(viewModel.searchText.isEmpty ? "No equipment yet" : "No matches")
                    .foregroundStyle(.secondary)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.visibleItems) { item in
                    EquipmentRowCard(
                        item: item,
                        onSelect: { presentEditSheet(for: item) },
                        onToggleEquipped: { item.isCurrentlyEquipped.toggle() }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            viewModel.requestDelete(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }

            addButtonRow
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 0)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .bottom)
    }

    private var headerOverlay: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                Text("Equipment")
                    .font(.title2)
                    .bold()

                Spacer()

                Text(viewModel.headerEncumbranceText)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: .capsule)
                    .overlay {
                        if viewModel.isEncumbranceOverLimit {
                            Capsule()
                                .stroke(.red, lineWidth: 1)
                        } else {
                            Capsule()
                                .stroke(.quaternary, lineWidth: 1)
                        }
                    }
            }

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search equipment", text: $viewModel.searchText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.white.opacity(0.45), lineWidth: 0.7)
            }
            .shadow(color: .white.opacity(0.25), radius: 1, x: 0, y: -0.5)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var addButtonRow: some View {
        HStack {
            Spacer()

            Button {
                presentedEditor = .add
            } label: {
                Text("Add new item")
                    .font(.headline)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(.quaternary, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("equipment.addItem")

            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 96)
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private var isShowingDeleteAlert: Binding<Bool> {
        Binding(
            get: { viewModel.pendingDeleteItem != nil },
            set: { isPresented in
                if isPresented == false {
                    viewModel.cancelDelete()
                }
            }
        )
    }

    private func presentEditSheet(for item: CharacterEquipmentItem) {
        presentedEditor = .edit(item)
    }
}

private struct EquipmentEditorSheet: Identifiable {
    let id: UUID
    let item: CharacterEquipmentItem?
    let title: String
    let name: String
    let encumbrance: Int
    let notes: String

    static var add: EquipmentEditorSheet {
        EquipmentEditorSheet(
            id: UUID(),
            item: nil,
            title: "Add Equipment",
            name: "",
            encumbrance: 0,
            notes: ""
        )
    }

    static func edit(_ item: CharacterEquipmentItem) -> EquipmentEditorSheet {
        EquipmentEditorSheet(
            id: UUID(),
            item: item,
            title: "Edit Equipment",
            name: item.name,
            encumbrance: item.encumbrance,
            notes: item.notes
        )
    }
}

private struct EquipmentRowCard: View {
    let item: CharacterEquipmentItem
    let onSelect: () -> Void
    let onToggleEquipped: () -> Void

    private var displayName: String {
        let trimmed = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Unnamed item" : trimmed
    }

    private var hasNotes: Bool {
        item.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onSelect) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(displayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)

                        Spacer(minLength: 8)

                        Text("ENC \(item.encumbrance)")
                            .font(.subheadline)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }

                    if hasNotes {
                        Text(item.notes)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button(action: onToggleEquipped) {
                Image(systemName: item.isCurrentlyEquipped ? "checkmark.square.fill" : "square")
                    .font(.body)
                    .foregroundStyle(item.isCurrentlyEquipped ? .primary : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isCurrentlyEquipped ? "Unequip item" : "Equip item")
        }
        .padding(12)
        .background(Color(.systemBackground).opacity(0.52), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
