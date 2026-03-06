import Foundation
import SwiftData

@Model
final class CharacterEquipmentItem {
    var name: String
    private var storedEncumbrance: Int
    var encumbrance: Int {
        get { storedEncumbrance }
        set { storedEncumbrance = max(0, newValue) }
    }
    var notes: String
    var isEquipped: Bool
    var sortOrder: Int
    var character: RQCharacter?

    init(
        name: String = "",
        encumbrance: Int = 0,
        notes: String = "",
        isEquipped: Bool = false,
        sortOrder: Int = 0,
        character: RQCharacter? = nil
    ) {
        self.name = name
        self.storedEncumbrance = max(0, encumbrance)
        self.notes = notes
        self.isEquipped = isEquipped
        self.sortOrder = sortOrder
        self.character = character
    }
}
