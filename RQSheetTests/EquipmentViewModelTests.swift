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
}
