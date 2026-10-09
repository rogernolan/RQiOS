import Testing
@testable import RQSheet

struct CharacterMagicTests {
    @Test
    func magicDefaultsTrackPow() {
        let character = RQCharacter()

        #expect(character.runePoints == 3)
        #expect(character.maxMagicPoints == character.pow)
        #expect(character.currentMagicPoints == character.maxMagicPoints)
    }

    @Test
    func addSpellAssignsIncreasingSortOrder() {
        let character = RQCharacter()

        let bladesharp = character.addSpell(name: "Bladesharp", points: 2, page: "42", kind: .spiritMagic)
        let shield = character.addSpell(name: "Shield", points: 1, page: "67", kind: .runeSpell)

        #expect(bladesharp.sortOrder == 0)
        #expect(shield.sortOrder == 1)
        #expect(character.spells.map(\.name) == ["Bladesharp", "Shield"])
    }

    @Test
    func spellPointsClampToNonNegative() {
        let spell = CharacterSpell(name: "Demoralize", points: -4, page: "88", kind: .spiritMagic)

        #expect(spell.points == 0)
    }

    @Test
    func reducingPowRecalculatesMagicPointMaximumAndClampsCurrent() {
        let character = RQCharacter()
        character.pow = 12
        character.currentMagicPoints = 12
        #expect(character.maxMagicPoints == 12)
        #expect(character.currentMagicPoints == 12)

        character.pow = 6

        #expect(character.maxMagicPoints == 6)
        #expect(character.currentMagicPoints == 6)
    }

    @Test
    func settingPowToSixPreservesInitiallyLowerCurrentMagicPoints() {
        let character = RQCharacter()
        character.pow = 4
        character.currentMagicPoints = 4

        character.pow = 6

        #expect(character.maxMagicPoints == 6)
        #expect(character.currentMagicPoints == 4)
    }

    @Test
    func increasingPowRaisesMaximumWithoutForcingCurrentUpward() {
        let character = RQCharacter()
        character.pow = 4
        character.currentMagicPoints = 2
        #expect(character.maxMagicPoints == 4)
        #expect(character.currentMagicPoints == 2)

        character.pow = 10

        #expect(character.maxMagicPoints == 10)
        #expect(character.currentMagicPoints == 2)
    }
}
