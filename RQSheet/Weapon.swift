//
//  Weapon.swift
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
final class Weapon {
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

    var hpMax: Int? {
        didSet {
            guard let hpMax else { return }
            let clamped = max(1, hpMax)
            if hpMax != clamped {
                self.hpMax = clamped
                return
            }
            if let hpCurrent, hpCurrent > clamped {
                self.hpCurrent = clamped
            }
        }
    }

    var hpCurrent: Int? {
        didSet {
            guard let hpCurrent else { return }
            if let hpMax {
                let clamped = min(max(1, hpCurrent), hpMax)
                if hpCurrent != clamped {
                    self.hpCurrent = clamped
                }
                return
            }
            if hpCurrent < 1 {
                self.hpCurrent = 1
            }
        }
    }

    var enc: Int? {
        didSet {
            if let enc, enc < 0 {
                self.enc = 0
            }
        }
    }

    var strikeRank: String
    var type: WeaponType?
    var range: String
    var isEquipped: Bool

    init(
        character: RQCharacter? = nil,
        name: String,
        basePercentage: Int = 0,
        experienceCheck: Bool = false,
        damage: String = "",
        hpMax: Int? = nil,
        hpCurrent: Int? = nil,
        enc: Int? = nil,
        strikeRank: String = "",
        type: WeaponType? = nil,
        range: String = "",
        isEquipped: Bool = false
    ) {
        self.character = character
        self.name = name
        self.basePercentage = basePercentage.clampedPercentage
        self.experienceCheck = experienceCheck
        self.damage = damage

        let clampedHpMax = hpMax.map { max(1, $0) }
        self.hpMax = clampedHpMax
        if let hpCurrent, let hpMax = clampedHpMax {
            self.hpCurrent = min(max(1, hpCurrent), hpMax)
        } else {
            self.hpCurrent = hpCurrent.map { max(1, $0) }
        }

        self.enc = enc.map { max(0, $0) }
        self.strikeRank = strikeRank
        self.type = type
        self.range = range
        self.isEquipped = isEquipped
    }
}
