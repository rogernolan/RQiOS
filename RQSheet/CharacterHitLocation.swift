//
//  CharacterHitLocation.swift
//  RQSheet
//

import Foundation
import SwiftData

enum HitLocation: String, Codable, CaseIterable {
    case head
    case chest
    case abdomen
    case leftArm
    case rightArm
    case leftLeg
    case rightLeg
}

@Model
final class CharacterHitLocation {
    var character: RQCharacter?
    var location: HitLocation

    var maxHP: Int {
        didSet {
            if maxHP < 1 {
                maxHP = 1
            }
            if currentHP > maxHP {
                currentHP = maxHP
            }
        }
    }

    var currentHP: Int {
        didSet {
            if currentHP < 0 {
                currentHP = 0
            }
            if currentHP > maxHP {
                currentHP = maxHP
            }
        }
    }

    var armour: Int {
        didSet {
            if armour < 0 {
                armour = 0
            }
        }
    }

    init(
        character: RQCharacter? = nil,
        location: HitLocation,
        maxHP: Int,
        currentHP: Int,
        armour: Int = 0
    ) {
        let clampedMax = max(1, maxHP)
        self.character = character
        self.location = location
        self.maxHP = clampedMax
        self.currentHP = min(max(0, currentHP), clampedMax)
        self.armour = max(0, armour)
    }
}
