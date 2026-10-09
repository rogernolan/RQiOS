//  RuneAffinity.swift
//  RQSheet
//
//  Created by Roger Nolan on 21/02/2026.
//

import Foundation
import SwiftData

enum RuneName: String, Codable, CaseIterable {
    case fire = "Fire"
    case darkness = "Darkness"
    case earth = "Earth"
    case water = "Water"
    case air = "Air"
    case moon = "Moon"
    case man = "Man"
    case beast = "Beast"
    case fertility = "Fertility"
    case death = "Death"
    case harmony = "Harmony"
    case disorder = "Disorder"
    case truth = "Truth"
    case illusion = "Illusion"
    case stasis = "Stasis"
    case movement = "Movement"
}

@Model
final class RuneAffinity {
    var name: RuneName = RuneName.fire
    private(set) var percentage: Int = 0  // 0-100
    var experienceCheck: Bool = false
    @Relationship(deleteRule: .nullify, inverse: \RuneAffinity.pairedByRune)
    var relatedRune: RuneAffinity?
    var pairedByRune: RuneAffinity?
    var fireCharacter: RQCharacter?
    var darknessCharacter: RQCharacter?
    var earthCharacter: RQCharacter?
    var waterCharacter: RQCharacter?
    var airCharacter: RQCharacter?
    var moonCharacter: RQCharacter?
    var manCharacter: RQCharacter?
    var beastCharacter: RQCharacter?
    var fertilityCharacter: RQCharacter?
    var deathCharacter: RQCharacter?
    var harmonyCharacter: RQCharacter?
    var disorderCharacter: RQCharacter?
    var truthCharacter: RQCharacter?
    var IllusionCharacter: RQCharacter?
    var stasisCharacter: RQCharacter?
    var movementCharacter: RQCharacter?

    init(name: RuneName, percentage: Int = 0, experienceCheck: Bool = false) {
        self.name = name
        self.percentage = percentage.clampedPercentage
        self.experienceCheck = experienceCheck
    }

    func setPercentage(_ newValue: Int) {
        applyPercentage(newValue, syncPair: true)
    }

    private func applyPercentage(_ newValue: Int, syncPair: Bool) {
        let clampedValue = newValue.clampedPercentage
        if percentage == clampedValue {
            return
        }

        percentage = clampedValue

        guard syncPair, let relatedRune else { return }

        let pairedValue = 100 - clampedValue
        if relatedRune.percentage != pairedValue {
            relatedRune.applyPercentage(pairedValue, syncPair: false)
        }
    }
    
    class func relatedPair(lhName: RuneName, rhName: RuneName) -> (RuneAffinity, RuneAffinity) {
        let left = RuneAffinity(name: lhName, percentage: 50)
        let right = RuneAffinity(name: rhName, percentage: 50)
        left.relatedRune = right
        right.relatedRune = left
        return (left,right)
    }
}
