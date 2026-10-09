import SwiftData
import SwiftUI

struct SkillsView: View {
    let character: RQCharacter

    var body: some View {
        CharacterSkillsContentView(character: character)
            .mainRuneBackground(runeName: "RuneMastery")
    }
}

private struct CharacterSkillsContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var storedSkills: [CharacterSkill]

    let character: RQCharacter

    @State private var viewModel: SkillsViewModel
    @State private var presentedEditor: SkillEditorSheet?
    @State private var headerHeight: CGFloat = 44

    init(character: RQCharacter) {
        self.character = character
        _viewModel = State(initialValue: SkillsViewModel(character: character))
    }

    var body: some View {
        ZStack(alignment: .top) {
            skillsList
            headerOverlay
        }
        .sheet(item: $presentedEditor) { editor in
            SkillEditorView(
                title: editor.title,
                name: editor.name,
                percentage: editor.percentage
            ) { name, percentage in
                if let skill = editor.skill {
                    viewModel.updateSkill(skill, name: name, percentage: percentage, group: editor.group)
                } else {
                    viewModel.addSkill(name: name, percentage: percentage, group: editor.group)
                }
            }
        }
        .alert("This cannot be undone", isPresented: isShowingDeleteAlert) {
            Button("No", role: .cancel) {
                viewModel.cancelDelete()
            }
            Button("Yes", role: .destructive) {
                deletePendingSkill()
            }
        } message: {
            Text("Delete this skill?")
        }
    }

    private var skillsList: some View {
        List {
            Color.clear
                .frame(height: headerHeight + 16)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            ForEach(SkillGroup.allCases, id: \.rawValue) { group in
                let groupSkills = viewModel.filteredSkills(for: group, in: currentCharacterSkills)
                Section {
                    if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && groupSkills.isEmpty {
                        Text("No matches")
                            .foregroundStyle(.secondary)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(groupSkills) { skill in
                            SkillRowCard(
                                skill: skill,
                                onSelect: {
                                    presentedEditor = .edit(skill, group: group)
                                }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.requestDelete(skill)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                } header: {
                    groupHeader(for: group)
                } footer: {
                    addSkillRow(for: group)
                }
            }
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 0)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .bottom)
    }

    private var currentCharacterSkills: [CharacterSkill] {
        storedSkills.filter { $0.character?.persistentModelID == character.persistentModelID }
    }

    private var headerOverlay: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search skills", text: $viewModel.searchText)
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

    private func groupHeader(for group: SkillGroup) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text(groupTitle(for: group))
                .font(.headline)

            Spacer()

            Text(formattedBonus(character.bonus(for: group)))
                .font(.subheadline)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.top, 12)
        .padding(.bottom, 4)
        .textCase(nil)
    }

    private func addSkillRow(for group: SkillGroup) -> some View {
        HStack {
            Spacer()

            Button {
                presentedEditor = .add(group: group)
            } label: {
                Text("Add new skill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(.regularMaterial, in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(.quaternary, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("skills.add.\(group.rawValue)")

            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 12)
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private var isShowingDeleteAlert: Binding<Bool> {
        Binding(
            get: { viewModel.pendingDeleteSkill != nil },
            set: { isPresented in
                if isPresented == false {
                    viewModel.cancelDelete()
                }
            }
        )
    }

    private func deletePendingSkill() {
        guard let pendingSkill = viewModel.pendingDeleteSkill else { return }
        if let definition = pendingSkill.definition,
           definition.key.hasPrefix("custom."),
           definition.characterSkills.count <= 1 {
            modelContext.delete(definition)
        }
        modelContext.delete(pendingSkill)
        viewModel.confirmDelete()
    }

    private func formattedBonus(_ value: Int) -> String {
        let sign = value > 0 ? "+" : ""
        return "\(sign)\(value)%"
    }

    private func groupTitle(for group: SkillGroup) -> String {
        switch group {
        case .agility:
            return "Agility"
        case .communication:
            return "Communication"
        case .knowledge:
            return "Knowledge"
        case .manipulation:
            return "Manipulation"
        case .magic:
            return "Magic"
        case .perception:
            return "Perception"
        case .stealth:
            return "Stealth"
        }
    }
}

private struct SkillEditorSheet: Identifiable {
    let id: UUID
    let skill: CharacterSkill?
    let title: String
    let name: String
    let percentage: Int
    let group: SkillGroup

    static func add(group: SkillGroup) -> SkillEditorSheet {
        SkillEditorSheet(
            id: UUID(),
            skill: nil,
            title: "Add Skill",
            name: "",
            percentage: 0,
            group: group
        )
    }

    static func edit(_ skill: CharacterSkill, group: SkillGroup) -> SkillEditorSheet {
        SkillEditorSheet(
            id: UUID(),
            skill: skill,
            title: "Edit Skill",
            name: skill.displayName,
            percentage: skill.effectiveValue(),
            group: group
        )
    }
}

private struct SkillRowCard: View {
    let skill: CharacterSkill
    let onSelect: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: onSelect) {
                HStack(alignment: .center, spacing: 12) {
                    Text(skill.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)

                    Text("\(skill.effectiveValue())%")
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                skill.experienceCheck.toggle()
            } label: {
                Image(systemName: skill.experienceCheck ? "checkmark.square.fill" : "square")
                    .font(.body)
                    .foregroundStyle(skill.experienceCheck ? .primary : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Toggle experience check")
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
