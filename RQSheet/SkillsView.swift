//
//  SkillsView.swift
//  RQSheet
//

import SwiftUI
import SwiftData

struct SkillsView: View {
    @Query private var characters: [RQCharacter]
    @State private var searchText = ""

    private var character: RQCharacter? {
        characters.first
    }

    var body: some View {
        Group {
            if let character {
                ZStack(alignment: .top) {
                    List {
                        Color.clear
                            .frame(height: 48)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)

                        ForEach(SkillGroup.allCases, id: \.rawValue) { group in
                            let groupSkills = filteredSkills(for: character, group: group)
                            Section(groupTitle(for: group)) {
                                ForEach(groupSkills) { skill in
                                    SkillRowView(skill: skill)
                                }
                                if searchText.isEmpty == false && groupSkills.isEmpty {
                                    Text("No matches")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)

                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search skills", text: $searchText)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            } else {
                Text("Create a character in Summary to view skills.")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }

    private func skills(for character: RQCharacter, group: SkillGroup) -> [CharacterSkill] {
        character.skills
            .filter { $0.definition?.group == group }
            .sorted { lhs, rhs in
                (lhs.definition?.name ?? "") < (rhs.definition?.name ?? "")
            }
    }

    private func filteredSkills(for character: RQCharacter, group: SkillGroup) -> [CharacterSkill] {
        let groupSkills = skills(for: character, group: group)
        guard searchText.isEmpty == false else { return groupSkills }

        return groupSkills.filter { skill in
            let name = skill.definition?.name ?? ""
            return name.localizedCaseInsensitiveContains(searchText)
        }
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
        case .perception:
            return "Perception"
        case .stealth:
            return "Stealth"
        }
    }
}

private struct SkillRowView: View {
    @Bindable var skill: CharacterSkill

    var body: some View {
        HStack(spacing: 8) {
            Text(skill.definition?.name ?? "Unknown Skill")

            Spacer()

            Text("\(skill.effectiveValue())%")
                .monospacedDigit()
                .foregroundColor(.secondary)

            Button {
                skill.experienceCheck.toggle()
            } label: {
                Image(systemName: skill.experienceCheck ? "checkmark.square.fill" : "square")
                    .font(.body)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Toggle experience check")
        }
    }
}
