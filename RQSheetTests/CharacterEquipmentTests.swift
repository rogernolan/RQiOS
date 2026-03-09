import Testing
@testable import RQSheet

struct CharacterEquipmentTests {
    @Test
    func addEquipmentItemAssignsIncreasingSortOrder() {
        let character = RQCharacter()

        let rope = character.addEquipmentItem(name: "Rope", encumbrance: 1, notes: "", isCurrentlyEquipped: false)
        let shield = character.addEquipmentItem(name: "Shield", encumbrance: 2, notes: "", isCurrentlyEquipped: true)

        #expect(rope.sortOrder == 0)
        #expect(shield.sortOrder == 1)
        #expect(character.equipmentItems.map(\.name) == ["Rope", "Shield"])
    }

    @Test
    func encumbranceRulesClampAndSumCorrectly() {
        let character = RQCharacter()
        character.str = 11
        character.con = 15

        _ = character.addEquipmentItem(name: "Heavy Cloak", encumbrance: -3, notes: "", isCurrentlyEquipped: true)
        _ = character.addEquipmentItem(name: "Waterskin", encumbrance: 2, notes: "", isCurrentlyEquipped: false)
        _ = character.addEquipmentItem(name: "Spear", encumbrance: 3, notes: "", isCurrentlyEquipped: true)

        #expect(character.equipmentItems.map(\.encumbrance) == [0, 2, 3])
        #expect(character.currentEncumbrance == 3)
        #expect(character.maxEncumbrance == 11)
    }

    @Test
    func currentEncumbranceIncludesEquippedWeapons() {
        let character = RQCharacter()
        character.str = 12
        character.con = 12

        _ = character.addEquipmentItem(name: "Pack", encumbrance: 2, notes: "", isCurrentlyEquipped: true)
        character.weapons.append(Weapon(name: "Broadsword", damage: "1d8+1", enc: 1, isEquipped: true))
        character.weapons.append(Weapon(name: "Bow", damage: "1d8", enc: 2, isEquipped: false))
        character.weapons.append(Weapon(name: "Knife", damage: "1d4+2", enc: nil, isEquipped: true))

        #expect(character.currentEncumbrance == 3)
    }
}
