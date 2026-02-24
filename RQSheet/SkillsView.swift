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
                                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                        .listRowBackground(Color.clear)
                                }
                                if searchText.isEmpty == false && groupSkills.isEmpty {
                                    Text("No matches")
                                        .foregroundColor(.secondary)
                                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                        .listRowBackground(Color.clear)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .contentMargins(.horizontal, 16, for: .scrollContent)

                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search skills", text: $searchText)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.45), lineWidth: 0.7)
                    )
                    .shadow(color: .white.opacity(0.25), radius: 1, x: 0, y: -0.5)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            } else {
                Text("Create a character in Summary to view skills.")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .mainRuneBackground(runeName: "RuneMastery")
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
