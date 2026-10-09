import Testing
@testable import RQSheet

struct SkillsViewModelTests {
    @Test
    @MainActor
    func searchUsesCustomDisplayNames() {
        let character = RQCharacter()
        let definition = SkillDefinition(key: "jump", name: "Jump", group: .agility, baseRule: "0")
        let skill = CharacterSkill(character: character, definition: definition, successPercentage: 15)
        skill.customName = "Leap"
        character.skills.append(skill)

        let viewModel = SkillsViewModel(character: character)
        viewModel.searchText = "lea"

        #expect(viewModel.filteredSkills(for: .agility).map(\.displayName) == ["Leap"])
    }

    @Test
    @MainActor
    func filteredSkillsUseLatestQueryResultsForExperienceChecks() {
        let character = RQCharacter()
        let definition = SkillDefinition(key: "agility-boat", name: "Boat", group: .agility, baseRule: "0")
        let initiallyLoadedSkill = CharacterSkill(character: character, definition: definition, successPercentage: 5)
        character.skills.append(initiallyLoadedSkill)
        let viewModel = SkillsViewModel(character: character)
        let refreshedSkill = CharacterSkill(
            character: character,
            definition: definition,
            successPercentage: 5,
            experienceCheck: true
        )

        let displayedSkills = viewModel.filteredSkills(for: .agility, in: [refreshedSkill])

        #expect(displayedSkills.count == 1)
        #expect(displayedSkills[0] === refreshedSkill)
        #expect(displayedSkills[0].experienceCheck)
    }

    @Test
    @MainActor
    func anEmptyQueryResultDoesNotRestoreStaleRelationshipSkills() {
        let character = RQCharacter()
        let definition = SkillDefinition(key: "jump", name: "Jump", group: .agility, baseRule: "0")
        let staleSkill = CharacterSkill(character: character, definition: definition, successPercentage: 15)
        character.skills.append(staleSkill)
        let viewModel = SkillsViewModel(character: character)

        #expect(viewModel.filteredSkills(for: .agility).count == 1)
        #expect(viewModel.filteredSkills(for: .agility, in: []).isEmpty)
    }

    @Test
    @MainActor
    func queryResultsUseCurrentGroupsAndSearchNames() {
        let character = RQCharacter()
        let definition = SkillDefinition(key: "battle-lore", name: "Battle Lore", group: .knowledge, baseRule: "0")
        let refreshedSkill = CharacterSkill(character: character, definition: definition, successPercentage: 20)
        refreshedSkill.customName = "Ship Lore"
        let otherGroupDefinition = SkillDefinition(key: "ship-sailing", name: "Ship Sailing", group: .agility, baseRule: "0")
        let otherGroupSkill = CharacterSkill(character: character, definition: otherGroupDefinition, successPercentage: 35)
        let viewModel = SkillsViewModel(character: character)
        viewModel.searchText = " ship "

        let knowledge = viewModel.filteredSkills(for: .knowledge, in: [otherGroupSkill, refreshedSkill])
        let agility = viewModel.filteredSkills(for: .agility, in: [refreshedSkill, otherGroupSkill])

        #expect(knowledge.count == 1)
        #expect(knowledge.first === refreshedSkill)
        #expect(agility.count == 1)
        #expect(agility.first === otherGroupSkill)
        #expect(viewModel.filteredSkills(for: .knowledge, in: [otherGroupSkill]).isEmpty)
    }

    @Test
    @MainActor
    func addSkillCreatesCustomSkillInRequestedGroup() {
        let character = RQCharacter()
        let viewModel = SkillsViewModel(character: character)

        let skill = viewModel.addSkill(name: "Battle Lore", percentage: 35, group: .knowledge)

        #expect(character.skills.count == 1)
        #expect(skill.displayName == "Battle Lore")
        #expect(skill.resolvedGroup == .knowledge)
        #expect(skill.effectiveValue() == 35)
    }

    @Test
    @MainActor
    func updateSkillEditsOnlyTheLocalValues() {
        let character = RQCharacter()
        let definition = SkillDefinition(key: "scan", name: "Scan", group: .perception, baseRule: "10")
        let skill = CharacterSkill(character: character, definition: definition, successPercentage: 0)
        character.skills.append(skill)
        let viewModel = SkillsViewModel(character: character)

        viewModel.updateSkill(skill, name: "Spot Weakness", percentage: 45, group: .perception)

        #expect(skill.displayName == "Spot Weakness")
        #expect(skill.effectiveValue() == 45)
        #expect(definition.name == "Scan")
    }

    @Test
    @MainActor
    func deleteConfirmationStateRemovesSkillOnConfirm() {
        let character = RQCharacter()
        let definition = SkillDefinition(key: "jump", name: "Jump", group: .agility, baseRule: "0")
        let skill = CharacterSkill(character: character, definition: definition, successPercentage: 5)
        character.skills.append(skill)
        let viewModel = SkillsViewModel(character: character)

        viewModel.requestDelete(skill)
        #expect(viewModel.pendingDeleteSkill === skill)

        viewModel.confirmDelete()

        #expect(viewModel.pendingDeleteSkill == nil)
        #expect(character.skills.isEmpty)
    }
}
