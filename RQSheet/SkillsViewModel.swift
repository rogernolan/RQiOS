import Foundation
import Observation

@MainActor
@Observable
final class SkillsViewModel {
    let character: RQCharacter
    var searchText = ""
    var pendingDeleteSkill: CharacterSkill?

    init(character: RQCharacter) {
        self.character = character
    }

    func filteredSkills(for group: SkillGroup) -> [CharacterSkill] {
        let orderedSkills = character.skills
            .filter { $0.resolvedGroup == group }
            .sorted { lhs, rhs in
                lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
            }

        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.isEmpty == false else {
            return orderedSkills
        }

        return orderedSkills.filter { skill in
            skill.displayName.localizedStandardContains(trimmedQuery)
        }
    }

    @discardableResult
    func addSkill(name: String, percentage: Int, group: SkillGroup) -> CharacterSkill {
        character.addSkill(name: name, percentage: percentage, group: group)
    }

    func updateSkill(_ skill: CharacterSkill, name: String, percentage: Int, group: SkillGroup) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        skill.customName = trimmedName
        skill.customGroup = group
        skill.setEffectiveValue(percentage)
    }

    func requestDelete(_ skill: CharacterSkill) {
        pendingDeleteSkill = skill
    }

    func cancelDelete() {
        pendingDeleteSkill = nil
    }

    func confirmDelete() {
        guard let pendingDeleteSkill else { return }
        character.skills.removeAll { $0 == pendingDeleteSkill }
        self.pendingDeleteSkill = nil
    }
}
