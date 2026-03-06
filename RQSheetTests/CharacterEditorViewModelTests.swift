import Foundation
import Testing
@testable import RQSheet

struct CharacterEditorViewModelTests {
    @Test
    @MainActor
    func sectionStateToggles() {
        let character = RQCharacter()
        let viewModel = CharacterEditorViewModel(character: character)

        #expect(viewModel.expandedSections.contains(.identity))
        viewModel.toggle(.identity)
        #expect(viewModel.expandedSections.contains(.identity) == false)
    }

    @Test
    @MainActor
    func allCoreSectionsExist() {
        let viewModel = CharacterEditorViewModel(character: RQCharacter())

        #expect(viewModel.availableSections.contains(.identity))
        #expect(viewModel.availableSections.contains(.characteristics))
        #expect(viewModel.availableSections.contains(.social))
        #expect(viewModel.availableSections.contains(.passions))
    }

    @Test
    @MainActor
    func applyRolledStatUsesSetCharacteristicPath() {
        let character = RQCharacter()
        let viewModel = CharacterEditorViewModel(character: character)

        viewModel.applyCharacteristic(.str, value: 18)
        #expect(character.str == 18)
    }

    @Test
    @MainActor
    func passionsCrudAndReorderPersistSortOrder() {
        let character = RQCharacter()
        let viewModel = CharacterEditorViewModel(character: character)

        viewModel.addPassion(description: "Loyalty", percentage: 60)
        viewModel.addPassion(description: "Hate", percentage: 70)
        viewModel.movePassions(from: IndexSet(integer: 1), to: 0)

        let ordered = character.passions.sorted { $0.sortOrder < $1.sortOrder }
        #expect(ordered.count == 2)
        #expect(ordered[0].descriptionText == "Hate")
    }

    @Test
    @MainActor
    func parseAndRollValidationStateBehavesForInvalidFormula() {
        let viewModel = CharacterEditorViewModel(character: RQCharacter())

        viewModel.setCustomExpression("not-a-formula", for: .str)

        #expect(viewModel.rollValidationError(for: .str) != nil)
    }

    @Test
    @MainActor
    func deletingPassionReindexesSortOrder() {
        let viewModel = CharacterEditorViewModel(character: RQCharacter())
        viewModel.addPassion(description: "A", percentage: 50)
        viewModel.addPassion(description: "B", percentage: 60)

        viewModel.deletePassions(at: IndexSet(integer: 0))
        let ordered = viewModel.character.passions.sorted { $0.sortOrder < $1.sortOrder }

        #expect(ordered.count == 1)
        #expect(ordered[0].sortOrder == 0)
    }
}
