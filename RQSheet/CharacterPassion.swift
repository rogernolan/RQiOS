import Foundation
import SwiftData

@Model
final class CharacterPassion {
    var descriptionText: String
    var percentage: Int {
        didSet {
            let clamped = percentage.clampedPercentage
            if percentage != clamped {
                percentage = clamped
            }
        }
    }
    var sortOrder: Int
    var character: RQCharacter?

    init(descriptionText: String = "", percentage: Int = 0, sortOrder: Int = 0, character: RQCharacter? = nil) {
        self.descriptionText = descriptionText
        self.percentage = percentage.clampedPercentage
        self.sortOrder = sortOrder
        self.character = character
    }
}
