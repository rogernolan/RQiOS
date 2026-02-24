//
//  WeaponSkill.swift
//  RQSheet
//

import Foundation
import SwiftData

enum WeaponType: String, Codable, CaseIterable {
    case crushing = "crushing"
    case impaling = "impaling"
    case slashing = "slashing"
    case cutAndThrust = "cut-and-thrust"
    case handToHand = "hand-to-hand"
}

@Model
final class WeaponSkill {
    var character: RQCharacter?

    var name: String

    var basePercentage: Int {
        didSet {
            let clamped = basePercentage.clampedPercentage
            if basePercentage != clamped {
                basePercentage = clamped
            }
        }
    }
    var experienceCheck: Bool

    var damage: String

    var hpMax: Int {
        didSet {
            if hpMax < 1 {
                hpMax = 1
            }
            if hpCurrent > hpMax {
                hpCurrent = hpMax
            }
        }
    }

    var hpCurrent: Int {
        didSet {
            if hpCurrent < 1 {
                hpCurrent = 1
            }
            if hpCurrent > hpMax {
                hpCurrent = hpMax
            }
        }
    }

    var enc: Int {
        didSet {
            if enc < 0 {
                enc = 0
            }
        }
    }

    var strikeRank: Int {
        didSet {
            if strikeRank < 0 {
                strikeRank = 0
            }
        }
    }

    var type: WeaponType

    init(
        character: RQCharacter? = nil,
        name: String,
        basePercentage: Int = 0,
        experienceCheck: Bool = false,
        damage: String = "",
        hpMax: Int = 1,
        hpCurrent: Int = 1,
        enc: Int = 0,
        strikeRank: Int = 0,
        type: WeaponType
    ) {
        self.character = character
        self.name = name
        self.basePercentage = basePercentage.clampedPercentage
        self.experienceCheck = experienceCheck
        self.damage = damage

        let clampedHpMax = max(1, hpMax)
        self.hpMax = clampedHpMax
        self.hpCurrent = min(max(1, hpCurrent), clampedHpMax)

        self.enc = max(0, enc)
        self.strikeRank = max(0, strikeRank)
        self.type = type
    }
}
