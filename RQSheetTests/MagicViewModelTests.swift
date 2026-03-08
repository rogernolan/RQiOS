import Testing
@testable import RQSheet

struct MagicViewModelTests {
    @Test
    @MainActor
    func spellsAreGroupedByKindInInsertionOrder() {
        let character = RQCharacter()
        _ = character.addSpell(name: "Bladesharp", points: 2, page: "42", kind: .spiritMagic)
        _ = character.addSpell(name: "Shield", points: 1, page: "67", kind: .runeSpell)
        _ = character.addSpell(name: "Mobility", points: 2, page: "13", kind: .spiritMagic)

        let viewModel = MagicViewModel(character: character)

        #expect(viewModel.visibleSpiritSpells.map(\.name) == ["Bladesharp", "Mobility"])
        #expect(viewModel.visibleRuneSpells.map(\.name) == ["Shield"])
    }

    @Test
    @MainActor
    func searchRanksNameMatchesBeforePageMatchesWithinEachSection() {
        let character = RQCharacter()
        _ = character.addSpell(name: "Firearrow", points: 2, page: "12", kind: .spiritMagic)
        _ = character.addSpell(name: "Heal", points: 1, page: "fire chapter", kind: .spiritMagic)
        _ = character.addSpell(name: "Fireblade", points: 2, page: "44", kind: .runeSpell)
        _ = character.addSpell(name: "Shield", points: 1, page: "fire appendix", kind: .runeSpell)

        let viewModel = MagicViewModel(character: character)
        viewModel.searchText = "fire"

        #expect(viewModel.visibleSpiritSpells.map(\.name) == ["Firearrow", "Heal"])
        #expect(viewModel.visibleRuneSpells.map(\.name) == ["Fireblade", "Shield"])
    }

    @Test
    @MainActor
    func commonRuneSpellCatalogIsVisibleAndSearchable() {
        let character = RQCharacter()
        let viewModel = MagicViewModel(character: character)

        #expect(viewModel.visibleCommonRuneSpells.first?.name == "Command Cult Spirit")

        viewModel.searchText = "347"
        #expect(viewModel.visibleCommonRuneSpells.map(\.name) == ["Warding"])
    }

    @Test
    @MainActor
    func headerValuesExposeCastingMagicPointsAndRunePoints() {
        let character = RQCharacter()
        character.pow = 11
        character.currentMagicPoints = 7
        character.runePoints = 4

        let viewModel = MagicViewModel(character: character)

        #expect(viewModel.spiritCastingPercentageText == "55%")
        #expect(viewModel.magicPointsText == "7 / 11")
        #expect(viewModel.runePointsText == "4")
    }

    @Test
    @MainActor
    func addEditAndDeleteHelpersMutateCharacterSpellCollection() {
        let character = RQCharacter()
        let viewModel = MagicViewModel(character: character)

        let spell = viewModel.addNewSpell(name: "Bladesharp", points: 2, page: "42", kind: .spiritMagic)
        viewModel.updateSpell(spell, name: "Bladesharp 2", points: -3, page: "43")

        #expect(character.spells.count == 1)
        #expect(character.spells[0].name == "Bladesharp 2")
        #expect(character.spells[0].points == 0)
        #expect(character.spells[0].page == "43")

        viewModel.requestDelete(spell)
        #expect(viewModel.pendingDeleteSpell === spell)

        viewModel.confirmDelete()
        #expect(viewModel.pendingDeleteSpell == nil)
        #expect(character.spells.isEmpty)
    }

    @Test
    @MainActor
    func pointEditorsClampCurrentMagicPointsAndRunePoints() {
        let character = RQCharacter()
        character.pow = 9

        let viewModel = MagicViewModel(character: character)
        viewModel.updateCurrentMagicPoints(-4)
        viewModel.updateRunePoints(-2)

        #expect(character.currentMagicPoints == 0)
        #expect(character.runePoints == 0)
    }
}
