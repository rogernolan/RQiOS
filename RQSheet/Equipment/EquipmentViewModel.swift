import Foundation
import Observation

@MainActor
@Observable
final class EquipmentViewModel {
    let character: RQCharacter
    var searchText: String = ""

    init(character: RQCharacter) {
        self.character = character
    }

    var sortedItems: [CharacterEquipmentItem] {
        character.equipmentItems.sorted { lhs, rhs in
            if lhs.sortOrder == rhs.sortOrder {
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
            return lhs.sortOrder < rhs.sortOrder
        }
    }

    var filteredItems: [CharacterEquipmentItem] {
        let query = normalizedQuery
        guard query.isEmpty == false else {
            return sortedItems
        }

        let ranked = sortedItems.compactMap { item -> (item: CharacterEquipmentItem, rank: Int)? in
            let name = item.name.lowercased()
            let notes = item.notes.lowercased()

            if name.contains(query) {
                return (item, 0)
            }
            if notes.contains(query) {
                return (item, 1)
            }

            return nil
        }

        return ranked.sorted { lhs, rhs in
            if lhs.rank == rhs.rank {
                if lhs.item.sortOrder == rhs.item.sortOrder {
                    return lhs.item.name.localizedCaseInsensitiveCompare(rhs.item.name) == .orderedAscending
                }
                return lhs.item.sortOrder < rhs.item.sortOrder
            }
            return lhs.rank < rhs.rank
        }.map(\.item)
    }

    var totalEncumbrance: Int {
        character.equipmentItems.reduce(0) { total, item in
            total + max(0, item.encumbrance)
        }
    }

    var equippedEncumbrance: Int {
        character.equipmentItems.reduce(0) { total, item in
            total + (item.isEquipped ? max(0, item.encumbrance) : 0)
        }
    }

    var encumbranceSummaryText: String {
        "\(equippedEncumbrance) / \(totalEncumbrance)"
    }

    private var normalizedQuery: String {
        searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
