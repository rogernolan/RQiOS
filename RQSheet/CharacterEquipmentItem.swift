import Foundation
import SwiftData

@Model
final class CharacterEquipmentItem {
    var name: String = ""
    var encumbrance: Int = 0 {
        didSet {
            if encumbrance < 0 {
                encumbrance = 0
            }
        }
    }
    var notes: String = ""
    var isCurrentlyEquipped: Bool = false
    var sortOrder: Int = 0
    var character: RQCharacter?

    init(
        name: String = "",
        encumbrance: Int = 0,
        notes: String = "",
        isCurrentlyEquipped: Bool = false,
        sortOrder: Int = 0,
        character: RQCharacter? = nil
    ) {
        self.name = name
        self.encumbrance = max(0, encumbrance)
        self.notes = notes
        self.isCurrentlyEquipped = isCurrentlyEquipped
        self.sortOrder = sortOrder
        self.character = character
    }
}
