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
        _ = character.addEquipmentItem(name: "Shield", encumbrance: 2, notes: "", isCurrentlyEquipped: true)
        _ = character.addEquipmentItem(name: "Rope", encumbrance: 1, notes: "", isCurrentlyEquipped: false)

        let viewModel = EquipmentViewModel(character: character)

        #expect(viewModel.visibleItems.map(\.name) == ["Shield", "Rope"])
        #expect(viewModel.headerEncumbranceText == "\(character.maxEncumbrance) / \(character.currentEncumbrance)")
    }

    @Test
    @MainActor
    func addNewItemAppendsBlankItemAtEndOfInsertionOrder() {
        let character = RQCharacter()
        _ = character.addEquipmentItem(name: "Shield", encumbrance: 2, notes: "", isCurrentlyEquipped: true)
        let viewModel = EquipmentViewModel(character: character)

        let newItem = viewModel.addNewItem()

        #expect(character.equipmentItems.count == 2)
        #expect(newItem.name.isEmpty)
        #expect(newItem.sortOrder == 1)
        #expect(viewModel.visibleItems.last === newItem)
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
}
