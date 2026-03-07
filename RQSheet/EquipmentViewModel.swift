import Foundation
import Observation

@MainActor
@Observable
final class EquipmentViewModel {
    let character: RQCharacter
    var searchText = ""
    var pendingDeleteItem: CharacterEquipmentItem?

    init(character: RQCharacter) {
        self.character = character
    }

    var visibleItems: [CharacterEquipmentItem] {
        let orderedItems = character.equipmentItems.sorted { lhs, rhs in
            lhs.sortOrder < rhs.sortOrder
        }

        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.isEmpty == false else {
            return orderedItems
        }

        let nameMatches = orderedItems.filter { item in
            item.name.localizedStandardContains(trimmedQuery)
        }
        let noteMatches = orderedItems.filter { item in
            item.name.localizedStandardContains(trimmedQuery) == false &&
            item.notes.localizedStandardContains(trimmedQuery)
        }

        return nameMatches + noteMatches
    }

    var headerEncumbranceText: String {
        "\(character.maxEncumbrance) / \(character.currentEncumbrance)"
    }
}
