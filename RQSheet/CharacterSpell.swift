import Foundation
import SwiftData

enum SpellKind: String, Codable, CaseIterable {
    case spiritMagic
    case runeSpell
}

@Model
final class CharacterSpell {
    var name: String
    var points: Int {
        didSet {
            if points < 0 {
                points = 0
            }
        }
    }
    var page: String
    var kindRawValue: String
    var sortOrder: Int
    var character: RQCharacter?

    var kind: SpellKind {
        get { SpellKind(rawValue: kindRawValue) ?? .spiritMagic }
        set { kindRawValue = newValue.rawValue }
    }

    init(
        name: String = "",
        points: Int = 0,
        page: String = "",
        kind: SpellKind = .spiritMagic,
        sortOrder: Int = 0,
        character: RQCharacter? = nil
    ) {
        self.name = name
        self.points = max(0, points)
        self.page = page
        self.kindRawValue = kind.rawValue
        self.sortOrder = sortOrder
        self.character = character
    }
}
