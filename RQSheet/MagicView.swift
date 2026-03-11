import SwiftData
import SwiftUI

struct MagicView: View {
    let character: RQCharacter

    var body: some View {
        CharacterMagicContentView(character: character)
            .mainRuneBackground(runeName: "RuneMagic")
    }
}

private struct CharacterMagicContentView: View {
    @Environment(\.modelContext) private var modelContext

    let character: RQCharacter

    @State private var viewModel: MagicViewModel
    @State private var presentedEditor: SpellEditorSheet?
    @State private var headerHeight: CGFloat = 44

    init(character: RQCharacter) {
        self.character = character
        _viewModel = State(initialValue: MagicViewModel(character: character))
    }

    var body: some View {
        ZStack(alignment: .top) {
            spellList
            headerOverlay
        }
        .sheet(item: $presentedEditor) { editor in
            SpellEditorView(
                title: editor.title,
                name: editor.name,
                points: editor.points,
                page: editor.page
            ) { name, points, page in
                if let spell = editor.spell {
                    viewModel.updateSpell(spell, name: name, points: points, page: page)
                } else {
                    viewModel.addNewSpell(name: name, points: points, page: page, kind: editor.kind)
                }
            }
        }
        .alert("This cannot be undone", isPresented: isShowingDeleteAlert) {
            Button("No", role: .cancel) {
                viewModel.cancelDelete()
            }
            Button("Yes", role: .destructive) {
                if let pending = viewModel.pendingDeleteSpell {
                    modelContext.delete(pending)
                }
                viewModel.confirmDelete()
            }
        } message: {
            Text("Delete this spell?")
        }
    }

    private var spellList: some View {
        List {
            Color.clear
                .frame(height: headerHeight + 16)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            spiritSectionHeaderRow

            if viewModel.visibleSpiritSpells.isEmpty {
                emptyStateRow(text: viewModel.searchText.isEmpty ? "No spirit magic yet" : "No spirit magic matches")
            } else {
                ForEach(viewModel.visibleSpiritSpells) { spell in
                    spellRow(spell)
                }
            }

            spiritAddButtonRow

            runeSectionHeaderRow

            if viewModel.visibleRuneSpells.isEmpty {
                emptyStateRow(text: viewModel.searchText.isEmpty ? "No rune spells yet" : "No rune spell matches")
            } else {
                ForEach(viewModel.visibleRuneSpells) { spell in
                    spellRow(spell)
                }
            }

            runeAddButtonRow

            commonSectionHeaderRow

            if viewModel.visibleCommonRuneSpells.isEmpty {
                emptyStateRow(text: "No common rune spell matches")
            } else {
                ForEach(viewModel.visibleCommonRuneSpells) { spell in
                    commonSpellRow(spell)
                }
            }

            Color.clear
                .frame(height: 88)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 0)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .bottom)
    }

    private var headerOverlay: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search magic", text: $viewModel.searchText)
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
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .onGeometryChange(for: CGFloat.self) { geometry in
            geometry.size.height
        } action: { _, newHeight in
            headerHeight = newHeight
        }
    }

    private var spiritSectionHeaderRow: some View {
        sectionRow {
            SpellSectionHeader(
                title: "Spirit Magic",
                subtitle: viewModel.spiritCastingPercentageText,
                trailingControl: {
                    MagicPointsEditor(
                        current: Binding(
                            get: { character.currentMagicPoints },
                            set: { viewModel.updateCurrentMagicPoints($0) }
                        ),
                        maxPoints: character.maxMagicPoints
                    )
                }
            )
        }
    }

    private var runeSectionHeaderRow: some View {
        sectionRow {
            SpellSectionHeader(
                title: "Rune Spells",
                subtitle: nil,
                trailingControl: {
                    RunePointsEditor(
                        value: Binding(
                            get: { character.runePoints },
                            set: { viewModel.updateRunePoints($0) }
                        )
                    )
                }
            )
        }
    }

    private var commonSectionHeaderRow: some View {
        sectionRow {
            SpellSectionHeader(
                title: "Common Rune Spells",
                subtitle: nil
            ) {
                EmptyView()
            }
        }
    }

    private var spiritAddButtonRow: some View {
        addButtonRow {
            presentedEditor = .add(kind: .spiritMagic)
        }
    }

    private var runeAddButtonRow: some View {
        addButtonRow {
            presentedEditor = .add(kind: .runeSpell)
        }
    }

    private func spellRow(_ spell: CharacterSpell) -> some View {
        SpellRowCard(
            name: spell.name,
            pointsText: "\(spell.points)",
            page: spell.page,
            onSelect: {
                presentedEditor = .edit(spell)
            }
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                viewModel.requestDelete(spell)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private func commonSpellRow(_ spell: CommonRuneSpellReference) -> some View {
        ReadOnlySpellRowCard(
            name: spell.name,
            pointsText: spell.pointsText,
            page: spell.page
        )
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private func emptyStateRow(text: String) -> some View {
        Text(text)
            .foregroundStyle(.secondary)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }

    private func sectionRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 4, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }

    private func addButtonRow(action: @escaping () -> Void) -> some View {
        HStack {
            Spacer()

            Button("Add new spell", action: action)
                .buttonStyle(.bordered)

            Spacer()
        }
        .padding(.top, 4)
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private var isShowingDeleteAlert: Binding<Bool> {
        Binding(
            get: { viewModel.pendingDeleteSpell != nil },
            set: { isPresented in
                if isPresented == false {
                    viewModel.cancelDelete()
                }
            }
        )
    }
}

private struct SpellEditorSheet: Identifiable {
    let id: UUID
    let spell: CharacterSpell?
    let kind: SpellKind
    let title: String
    let name: String
    let points: Int
    let page: String

    static func add(kind: SpellKind) -> SpellEditorSheet {
        SpellEditorSheet(
            id: UUID(),
            spell: nil,
            kind: kind,
            title: kind == .spiritMagic ? "Add Spirit Magic" : "Add Rune Spell",
            name: "",
            points: 0,
            page: ""
        )
    }

    static func edit(_ spell: CharacterSpell) -> SpellEditorSheet {
        SpellEditorSheet(
            id: UUID(),
            spell: spell,
            kind: spell.kind,
            title: spell.kind == .spiritMagic ? "Edit Spirit Magic" : "Edit Rune Spell",
            name: spell.name,
            points: spell.points,
            page: spell.page
        )
    }
}

private struct SpellSectionHeader<TrailingControl: View>: View {
    let title: String
    let subtitle: String?
    let trailingControl: TrailingControl

    init(
        title: String,
        subtitle: String?,
        @ViewBuilder trailingControl: () -> TrailingControl
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailingControl = trailingControl()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            titleGroup
            Spacer(minLength: 8)
            trailingControl
        }
    }

    private var titleGroup: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.headline)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}

private struct MagicPointsEditor: View {
    @Binding var current: Int
    let maxPoints: Int

    var body: some View {
        HStack(spacing: 6) {
            Text("MP")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("", value: $current, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
                .frame(width: 30)

            Text("/ \(maxPoints)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .stroke(.quaternary, lineWidth: 1)
        }
    }
}

private struct RunePointsEditor: View {
    @Binding var value: Int

    var body: some View {
        HStack(spacing: 6) {
            Text("RP")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("", value: $value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
                .frame(width: 30)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .stroke(.quaternary, lineWidth: 1)
        }
    }
}

private struct SpellRowCard: View {
    let name: String
    let pointsText: String
    let page: String
    let onSelect: () -> Void

    private var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Unnamed spell" : trimmed
    }

    private var displayPage: String {
        let trimmed = page.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "p-" : "p\(trimmed)"
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(displayName)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text(pointsText)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .frame(minWidth: 24, alignment: .trailing)

                Text(displayPage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 44, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.systemBackground).opacity(0.52), in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.quaternary, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(displayName)
    }
}

private struct ReadOnlySpellRowCard: View {
    let name: String
    let pointsText: String
    let page: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(name)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer(minLength: 8)

            Text(pointsText)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(minWidth: 24, alignment: .trailing)

            Text("p\(page)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(minWidth: 44, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemBackground).opacity(0.52), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
