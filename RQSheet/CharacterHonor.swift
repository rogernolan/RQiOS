import Foundation
import SwiftData

@Model
final class CharacterHonor {
    var descriptionText: String
    var percentage: Int {
        didSet {
            let clamped = percentage.clampedPercentage
            if percentage != clamped {
                percentage = clamped
            }
        }
    }
    var experienceCheck: Bool
    var character: RQCharacter?

    init(descriptionText: String = "", percentage: Int = 0, experienceCheck: Bool = false, character: RQCharacter? = nil) {
        self.descriptionText = descriptionText
        self.percentage = percentage.clampedPercentage
        self.experienceCheck = experienceCheck
        self.character = character
    }
}
