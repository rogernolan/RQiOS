import Testing
@testable import RQSheet

struct EquipmentViewModelTests {
    @Test
    @MainActor
    func searchRanksNameMatchesAheadOfNotesMatchesAndPreservesInsertionOrder() {
        let character = RQCharacter()
        _ = character.addEquipmentItem(name: "Fireblade", encumbrance: 2, notes: "Ceremonial sword", isCurrentlyEquipped: true)
        _ = character.addEquipmentItem(name: "Bedroll", encumbrance: 1, notes: "Smells like smoke and fire", isCurrentlyEquipped: false)
        _ = character.addEquipmentItem(name: "Firestarter", encumbrance: 0, notes: "Tinder kit", isCurrentlyEquipped: false)

        let viewModel = EquipmentViewModel(character: character)
        viewModel.searchText = "fire"

        #expect(viewModel.visibleItems.map(\.name) == ["Fireblade", "Firestarter", "Bedroll"])
    }

    @Test
    @MainActor
    func emptySearchReturnsInsertionOrder() {
        let character = RQCharacter()
        character.str = 10
        character.con = 10
        _ = character.addEquipmentItem(name: "Shield", encumbrance: 2, notes: "", isCurrentlyEquipped: true)
        _ = character.addEquipmentItem(name: "Rope", encumbrance: 1, notes: "", isCurrentlyEquipped: false)
        character.weapons.append(Weapon(name: "Spear", damage: "1d8+1", enc: 1, isEquipped: true))

        let viewModel = EquipmentViewModel(character: character)

        #expect(viewModel.visibleItems.map(\.name) == ["Shield", "Rope"])
        #expect(viewModel.headerEncumbranceText == "10 / 3")
        #expect(viewModel.isEncumbranceOverLimit == false)
    }

    @Test
    @MainActor
    func addNewItemAppendsAtEndOfInsertionOrder() {
        let character = RQCharacter()
        _ = character.addEquipmentItem(name: "Shield", encumbrance: 2, notes: "", isCurrentlyEquipped: true)
        let viewModel = EquipmentViewModel(character: character)

        let newItem = viewModel.addNewItem(name: "Rope", encumbrance: 1, notes: "Hemp")

        #expect(character.equipmentItems.count == 2)
        #expect(newItem.name == "Rope")
        #expect(newItem.notes == "Hemp")
        #expect(newItem.sortOrder == 1)
        #expect(viewModel.visibleItems.last === newItem)
    }

    @Test
    @MainActor
    func updateItemPersistsEditedValuesAndClampsEncumbrance() {
        let character = RQCharacter()
        let item = character.addEquipmentItem(name: "Shield", encumbrance: 2, notes: "Bronze", isCurrentlyEquipped: true)
        let viewModel = EquipmentViewModel(character: character)

        viewModel.updateItem(item, name: "Tower Shield", encumbrance: -4, notes: "Iron rim")

        #expect(item.name == "Tower Shield")
        #expect(item.encumbrance == 0)
        #expect(item.notes == "Iron rim")
    }

    @Test
    @MainActor
    func deleteConfirmationStateTracksPendingAndConfirmedDeletes() {
        let character = RQCharacter()
        let first = character.addEquipmentItem(name: "Shield", encumbrance: 2, notes: "", isCurrentlyEquipped: true)
        let second = character.addEquipmentItem(name: "Rope", encumbrance: 1, notes: "", isCurrentlyEquipped: false)
        let viewModel = EquipmentViewModel(character: character)

        viewModel.requestDelete(first)
        #expect(viewModel.pendingDeleteItem === first)

        viewModel.cancelDelete()
        #expect(viewModel.pendingDeleteItem == nil)
        #expect(character.equipmentItems.count == 2)

        viewModel.requestDelete(second)
        viewModel.confirmDelete()

        #expect(viewModel.pendingDeleteItem == nil)
        #expect(character.equipmentItems.count == 1)
        #expect(character.equipmentItems[0] === first)
    }

    @Test
    @MainActor
    func headerEncumbranceOverLimitMatchesCharacterTotals() {
        let character = RQCharacter()
        character.str = 8
        character.con = 12
        _ = character.addEquipmentItem(name: "Shield", encumbrance: 5, notes: "", isCurrentlyEquipped: true)
        _ = character.addEquipmentItem(name: "Pack", encumbrance: 4, notes: "", isCurrentlyEquipped: true)
        character.weapons.append(Weapon(name: "Longsword", damage: "1d8+1", enc: 1, isEquipped: true))

        let viewModel = EquipmentViewModel(character: character)

        #expect(viewModel.headerEncumbranceText == "8 / 10")
        #expect(viewModel.isEncumbranceOverLimit)
    }
}
