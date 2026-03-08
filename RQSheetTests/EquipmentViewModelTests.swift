import Testing
@testable import RQSheet

struct EquipmentViewModelTests {
    @Test
    @MainActor
    func searchPrioritizesNameMatchesOverNotesMatches() {
        let character = RQCharacter(name: "Arkat")
        character.addEquipmentItem(name: "Torch", encumbrance: 1, notes: "Light source", isEquipped: true)
        character.addEquipmentItem(name: "Rope", encumbrance: 1, notes: "Used with torch", isEquipped: false)

        let vm = EquipmentViewModel(character: character)
        vm.searchText = "torch"

        #expect(vm.filteredItems.count == 2)
        #expect(vm.filteredItems[0].name == "Torch")
    }

    @Test
    @MainActor
    func totalsComputeEquippedAndOverallEncumbrance() {
        let character = RQCharacter(name: "Arkat")
        character.addEquipmentItem(name: "Backpack", encumbrance: 2, notes: "", isEquipped: true)
        character.addEquipmentItem(name: "Bedroll", encumbrance: 1, notes: "", isEquipped: false)

        let vm = EquipmentViewModel(character: character)

        #expect(vm.totalEncumbrance == 3)
        #expect(vm.equippedEncumbrance == 2)
        #expect(vm.encumbranceSummaryText == "2 / 3")
    }
}
