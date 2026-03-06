import SwiftData
import Testing
@testable import RQSheet

struct CharacterEquipmentTests {
    @Test
    func addEquipmentItemAssignsSortOrderAndDefaults() {
        let character = RQCharacter(name: "Arkat")

        character.addEquipmentItem(name: "Backpack", encumbrance: 2, notes: "Worn", isEquipped: true)
        character.addEquipmentItem(name: "Bedroll", encumbrance: 1, notes: "", isEquipped: false)

        #expect(character.equipmentItems.count == 2)
        let ordered = character.equipmentItems.sorted { $0.sortOrder < $1.sortOrder }
        #expect(ordered[0].sortOrder == 0)
        #expect(ordered[1].sortOrder == 1)
        #expect(ordered[0].character === character)
    }

    @Test
    func equipmentEncumbranceIsClampedToNonNegative() {
        let item = CharacterEquipmentItem(name: "Torch", encumbrance: -2)
        #expect(item.encumbrance == 0)
        item.encumbrance = -9
        #expect(item.encumbrance == 0)
    }
}
