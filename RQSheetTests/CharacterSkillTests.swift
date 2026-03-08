import Testing
@testable import RQSheet

struct CharacterSkillTests {
    @Test
    func displayNameFallsBackToDefinitionUntilCustomNameIsSet() {
        let definition = SkillDefinition(key: "jump", name: "Jump", group: .agility, baseRule: "10")
        let skill = CharacterSkill(definition: definition, successPercentage: 5)

        #expect(skill.displayName == "Jump")

        skill.customName = "Leap"

        #expect(skill.displayName == "Leap")
        #expect(definition.name == "Jump")
    }

    @Test
    func resolvedGroupFallsBackToDefinitionAndCanBeOverridden() {
        let definition = SkillDefinition(key: "scan", name: "Scan", group: .perception, baseRule: "0")
        let skill = CharacterSkill(definition: definition, successPercentage: 0)

        #expect(skill.resolvedGroup == .perception)

        skill.customGroup = .knowledge

        #expect(skill.resolvedGroup == .knowledge)
    }

    @Test
    func setEffectiveValueStillClampsPercentagesForCustomSkills() {
        let character = RQCharacter()
        let definition = SkillDefinition(key: "custom", name: "Custom", group: .communication, baseRule: "0")
        let skill = CharacterSkill(character: character, definition: definition, successPercentage: 0)

        skill.setEffectiveValue(140)

        #expect(skill.effectiveValue() == 100)
    }
}
