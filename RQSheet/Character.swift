//  RQCharacter.swift
//  RQSheet
//
//  Created by Roger Nolan on 21/02/2026.
//

import Foundation
import SwiftData

struct SummaryRuneDisplay: Equatable {
    let name: RuneName
    let percentage: Int
    let isPlaceholder: Bool
}

private enum HitPointCharacteristic {
    case siz
    case pow
}

private func hitPointModifier(for value: Int, characteristic: HitPointCharacteristic) -> Int {
    switch characteristic {
    case .siz:
        switch value {
        case ...4: return -2
        case 5...8: return -1
        case 9...12: return 0
        case 13...16: return 1
        case 17...20: return 2
        case 21...24: return 3
        case 25...28: return 4
        default:
            return 4 + ((value - 25) / 4)
        }
    case .pow:
        switch value {
        case ...4: return -1
        case 5...16: return 0
        case 17...20: return 1
        case 21...24: return 2
        case 25...28: return 3
        default:
            return 3 + ((value - 25) / 4)
        }
    }
}

@Model
final class RQCharacter {
    enum Characteristic {
        case str
        case con
        case siz
        case dex
        case int
        case pow
        case cha
    }

    var name: String
    var worships: String

    var str: Int
    var con: Int
    var siz: Int
    var dex: Int
    var int: Int
    private var powValue: Int
    var cha: Int

    var pow: Int {
        get { powValue }
        set {
            powValue = newValue
            if currentMagicPointsValue > maxMagicPoints {
                currentMagicPointsValue = maxMagicPoints
            }
        }
    }

    var maxMagicPoints: Int {
        max(0, pow)
    }

    private var currentMagicPointsValue: Int
    var currentMagicPoints: Int {
        get { min(max(0, currentMagicPointsValue), maxMagicPoints) }
        set { currentMagicPointsValue = min(max(0, newValue), maxMagicPoints) }
    }

    private var runePointsValue: Int
    var runePoints: Int {
        get { max(0, runePointsValue) }
        set { runePointsValue = max(0, newValue) }
    }
    var maxHitpoints: Int {
        didSet {
            if maxHitpoints < 1 {
                maxHitpoints = 1
            }
            if currentHitpoints > maxHitpoints {
                currentHitpoints = maxHitpoints
            }
            syncHitLocationMaximums(preserveDamage: true)
        }
    }
    var currentHitpoints: Int {
        didSet {
            if currentHitpoints < 1 {
                currentHitpoints = 1
            }
            if currentHitpoints > maxHitpoints {
                currentHitpoints = maxHitpoints
            }
        }
    }
    var healingRate: Int {
        didSet {
            if healingRate < 1 {
                healingRate = 1
            }
        }
    }
    var move: Int {
        didSet {
            if move < 1 {
                move = 1
            }
        }
    }
    
    var reputation: Int {
        didSet {
            let clamped = reputation.clampedPercentage
            if reputation != clamped {
                reputation = clamped
            }
        }
    }
    var occupation: String
    var sol: String
    var income: Int
    var ransom: Int
    var dateOfBirth: String
    var family: String
    var patron: String
    var portraitData: Data?
    var powExperienceCheck: Bool
    var honor: CharacterHonor?
    var passions: [CharacterPassion] = []
    var equipmentItems: [CharacterEquipmentItem] = []
    var spells: [CharacterSpell] = []
    var skills: [CharacterSkill] = []
    var weaponSkills: [WeaponSkill] = []
    var hitLocations: [CharacterHitLocation] = []
    

    var fireAffinity: RuneAffinity = RuneAffinity(name: .fire, percentage: 0)
    var darknessAffinity = RuneAffinity(name: .darkness, percentage: 0)
    var earthAffinity = RuneAffinity(name: .earth, percentage: 0)
    var waterAffinity = RuneAffinity(name: .water, percentage: 0)
    var airAffinity = RuneAffinity(name: .air, percentage: 0)
    var moonAffinity = RuneAffinity(name: .moon, percentage: 0)
    
    // Related pairs with 50% each and relatedRune set
    
    var (manAffinity, beastAffinity) = RuneAffinity.relatedPair(lhName: .man, rhName: .beast)
    var (fertilityAffinity, deathAffinity) = RuneAffinity.relatedPair(lhName: .fertility, rhName: .death)
    var (harmonyAffinity, disorderAffinity) = RuneAffinity.relatedPair(lhName: .harmony, rhName: .disorder)
    var (truthAffinity, IllusionAffinity) = RuneAffinity.relatedPair(lhName: .truth, rhName: .illusion)
    var (stasisAffinity, movementAffinity) = RuneAffinity.relatedPair(lhName: .stasis, rhName: .movement)
    var summaryPlaceholderRuneNames: [RuneName]?

    var allRuneAffinities: [RuneAffinity] {
        [
            fireAffinity,
            darknessAffinity,
            earthAffinity,
            waterAffinity,
            airAffinity,
            moonAffinity,
            manAffinity,
            beastAffinity,
            fertilityAffinity,
            deathAffinity,
            harmonyAffinity,
            disorderAffinity,
            truthAffinity,
            IllusionAffinity,
            stasisAffinity,
            movementAffinity
        ]
    }

    func topSummaryRunes() -> [SummaryRuneDisplay] {
        let affinities = allRuneAffinities
        if affinities.contains(where: { isSummaryDefaultAffinity($0) == false }) {
            summaryPlaceholderRuneNames = nil
            return affinities
                .sorted { lhs, rhs in
                    if lhs.percentage == rhs.percentage {
                        return lhs.name.rawValue < rhs.name.rawValue
                    }
                    return lhs.percentage > rhs.percentage
                }
                .prefix(4)
                .map { affinity in
                    SummaryRuneDisplay(name: affinity.name, percentage: affinity.percentage, isPlaceholder: false)
                }
        }

        if summaryPlaceholderRuneNames?.count != 4 {
            summaryPlaceholderRuneNames = RuneName.allCases.shuffled().prefix(4).map(\.self)
        }

        return (summaryPlaceholderRuneNames ?? [])
            .compactMap { runeName in
                affinities.first(where: { $0.name == runeName })
            }
            .map { affinity in
                SummaryRuneDisplay(name: affinity.name, percentage: affinity.percentage, isPlaceholder: true)
            }
    }

    private func isSummaryDefaultAffinity(_ affinity: RuneAffinity) -> Bool {
        if affinity.relatedRune != nil {
            return affinity.percentage == 50
        }
        return affinity.percentage == 0
    }

    func agilityBonus() -> Int {
        let values: [(String, Int)] = [("STR", str), ("SIZ", siz), ("DEX", dex)]

        return values.reduce(0) { total, item in
            let (stat, value) = item

            let base: Int = {
                switch stat {
                case "STR":
                    switch value {
                    case ...4: return -5
                    case 5...16: return 0
                    case 17...20: return 5
                    default: return 5
                    }
                case "SIZ":
                    switch value {
                    case ...4: return 5
                    case 5...16: return 0
                    case 17...20: return -5
                    default: return -5
                    }
                case "DEX":
                    switch value {
                    case ...4: return -10
                    case 5...8: return -5
                    case 9...12: return 0
                    case 13...16: return 5
                    case 17...20: return 10
                    default: return 10
                    }
                default:
                    return 0
                }
            }()

            let stepBonus: Int = {
                guard value >= 21 else { return 0 }
                let steps = ((value - 21) / 4) + 1
                switch stat {
                case "STR", "DEX":
                    return steps * 5
                case "SIZ":
                    return -(steps * 5)
                default:
                    return 0
                }
            }()

            return total + base + stepBonus
        }
    }

    func communicationsBonus() -> Int {
        let values: [(String, Int)] = [("INT", int), ("POW", pow), ("CHA", cha)]

        return values.reduce(0) { total, item in
            let (stat, value) = item

            let base: Int = {
                switch stat {
                case "INT", "POW":
                    switch value {
                    case ...4: return -5
                    case 5...16: return 0
                    case 17...20: return 5
                    default: return 5
                    }
                case "CHA":
                    switch value {
                    case ...4: return -10
                    case 5...8: return -5
                    case 9...12: return 0
                    case 13...16: return 5
                    case 17...20: return 10
                    default: return 10
                    }
                default:
                    return 0
                }
            }()

            let stepBonus: Int = {
                guard value >= 21 else { return 0 }
                let steps = ((value - 21) / 4) + 1
                return steps * 5
            }()

            return total + base + stepBonus
        }
    }

    func knoledgeBonus() -> Int {
        let values: [(String, Int)] = [("INT", int), ("POW", pow)]

        return values.reduce(0) { total, item in
            let (stat, value) = item

            let base: Int = {
                switch stat {
                case "INT":
                    switch value {
                    case ...4: return -10
                    case 5...8: return -5
                    case 9...12: return 0
                    case 13...16: return 5
                    case 17...20: return 10
                    default: return 10
                    }
                case "POW":
                    switch value {
                    case ...4: return -5
                    case 5...16: return 0
                    case 17...20: return 5
                    default: return 5
                    }
                default:
                    return 0
                }
            }()

            let stepBonus: Int = {
                guard value >= 21 else { return 0 }
                let steps = ((value - 21) / 4) + 1
                return steps * 5
            }()

            return total + base + stepBonus
        }
    }

    func manipulationBonus() -> Int {
        let values: [(String, Int)] = [("STR", str), ("DEX", dex), ("INT", int), ("POW", pow)]

        return values.reduce(0) { total, item in
            let (stat, value) = item

            let base: Int = {
                switch stat {
                case "STR", "POW":
                    switch value {
                    case ...4: return -5
                    case 5...16: return 0
                    case 17...20: return 5
                    default: return 5
                    }
                case "DEX", "INT":
                    switch value {
                    case ...4: return -10
                    case 5...8: return -5
                    case 9...12: return 0
                    case 13...16: return 5
                    case 17...20: return 10
                    default: return 10
                    }
                default:
                    return 0
                }
            }()

            let stepBonus: Int = {
                guard value >= 21 else { return 0 }
                let steps = ((value - 21) / 4) + 1
                return steps * 5
            }()

            return total + base + stepBonus
        }
    }

    func stealthBonus() -> Int {
        let values: [(String, Int)] = [("SIZ", siz), ("DEX", dex), ("INT", int), ("POW", pow)]

        return values.reduce(0) { total, item in
            let (stat, value) = item

            let base: Int = {
                switch stat {
                case "SIZ":
                    switch value {
                    case ...4: return 10
                    case 5...8: return 5
                    case 9...12: return 0
                    case 13...16: return -5
                    case 17...20: return -10
                    default: return -10
                    }
                case "DEX", "INT":
                    switch value {
                    case ...4: return -10
                    case 5...8: return -5
                    case 9...12: return 0
                    case 13...16: return 5
                    case 17...20: return 10
                    default: return 10
                    }
                case "POW":
                    switch value {
                    case ...4: return 5
                    case 5...16: return 0
                    case 17...20: return -5
                    default: return -5
                    }
                default:
                    return 0
                }
            }()

            let stepBonus: Int = {
                guard value >= 21 else { return 0 }
                let steps = ((value - 21) / 4) + 1
                switch stat {
                case "SIZ", "POW":
                    return -(steps * 5)
                case "DEX", "INT":
                    return steps * 5
                default:
                    return 0
                }
            }()

            return total + base + stepBonus
        }
    }

    func perceptionBonus() -> Int {
        let values: [(String, Int)] = [("INT", int), ("POW", pow)]

        return values.reduce(0) { total, item in
            let (stat, value) = item

            let base: Int = {
                switch stat {
                case "INT":
                    switch value {
                    case ...4: return -10
                    case 5...8: return -5
                    case 9...12: return 0
                    case 13...16: return 5
                    case 17...20: return 10
                    default: return 10
                    }
                case "POW":
                    switch value {
                    case ...4: return -5
                    case 5...16: return 0
                    case 17...20: return 5
                    default: return 5
                    }
                default:
                    return 0
                }
            }()

            let stepBonus: Int = {
                guard value >= 21 else { return 0 }
                let steps = ((value - 21) / 4) + 1
                return steps * 5
            }()

            return total + base + stepBonus
        }
    }

    func bonus(for group: SkillGroup) -> Int {
        switch group {
        case .agility:
            return agilityBonus()
        case .communication:
            return communicationsBonus()
        case .knowledge:
            return knoledgeBonus()
        case .manipulation:
            return manipulationBonus()
        case .perception:
            return perceptionBonus()
        case .stealth:
            return stealthBonus()
        }
    }

    private static func hitLocationTemplate(for totalHitPoints: Int) -> (leg: Int, abdomen: Int, chest: Int, arm: Int, head: Int) {
        let total = max(1, totalHitPoints)
        switch total {
        case ...6:
            return (2, 2, 3, 1, 2)
        case 7...9:
            return (3, 3, 4, 2, 3)
        case 10...12:
            return (4, 4, 5, 3, 4)
        case 13...15:
            return (5, 5, 6, 4, 5)
        case 16...18:
            return (6, 6, 7, 5, 6)
        default:
            let bonus = max(0, (total - 19) / 3)
            return (7 + bonus, 7 + bonus, 8 + bonus, 6 + bonus, 7 + bonus)
        }
    }

    private static func hitLocationMaximum(for location: HitLocation, totalHitPoints: Int) -> Int {
        let template = hitLocationTemplate(for: totalHitPoints)
        switch location {
        case .leftLeg, .rightLeg:
            return template.leg
        case .abdomen:
            return template.abdomen
        case .chest:
            return template.chest
        case .leftArm, .rightArm:
            return template.arm
        case .head:
            return template.head
        }
    }

    private func syncHitLocationMaximums(preserveDamage: Bool) {
        for location in HitLocation.allCases {
            let targetMax = Self.hitLocationMaximum(for: location, totalHitPoints: maxHitpoints)
            if let existing = hitLocations.first(where: { $0.location == location }) {
                let damage = preserveDamage ? max(0, existing.maxHP - existing.currentHP) : 0
                existing.maxHP = targetMax
                existing.currentHP = max(0, targetMax - damage)
            } else {
                let newLocation = CharacterHitLocation(
                    character: self,
                    location: location,
                    maxHP: targetMax,
                    currentHP: targetMax,
                    armour: 0
                )
                hitLocations.append(newLocation)
            }
        }

        hitLocations.removeAll { location in
            HitLocation.allCases.contains(location.location) == false
        }
    }

    private static func generatedMaxHitpoints(con: Int, siz: Int, pow: Int) -> Int {
        max(
            1,
            con
                + hitPointModifier(for: siz, characteristic: .siz)
                + hitPointModifier(for: pow, characteristic: .pow)
        )
    }

    private func recalculateDerivedData() {
        if currentMagicPoints > maxMagicPoints {
            currentMagicPoints = maxMagicPoints
        }
        let recalculatedMax = Self.generatedMaxHitpoints(con: con, siz: siz, pow: pow)
        if recalculatedMax != maxHitpoints {
            maxHitpoints = recalculatedMax
            currentHitpoints = recalculatedMax
            syncHitLocationMaximums(preserveDamage: false)
        }
        for skill in skills {
            skill.refreshForCharacteristicChange()
        }
    }

    func setCharacteristic(_ characteristic: Characteristic, to value: Int) {
        switch characteristic {
        case .str:
            str = value
        case .con:
            con = value
        case .siz:
            siz = value
        case .dex:
            dex = value
        case .int:
            int = value
        case .pow:
            pow = value
        case .cha:
            cha = value
        }
        recalculateDerivedData()
    }

    @discardableResult
    func ensureHonorExists() -> CharacterHonor {
        if let honor {
            return honor
        }

        let createdHonor = CharacterHonor(character: self)
        honor = createdHonor
        return createdHonor
    }

    func addPassion(description: String, percentage: Int) {
        let nextSortOrder = (passions.map(\.sortOrder).max() ?? -1) + 1
        let passion = CharacterPassion(
            descriptionText: description,
            percentage: percentage.clampedPercentage,
            sortOrder: nextSortOrder,
            character: self
        )
        passions.append(passion)
    }

    var currentEncumbrance: Int {
        equipmentItems
            .filter(\.isCurrentlyEquipped)
            .reduce(0) { total, item in
                total + item.encumbrance
            }
    }

    var maxEncumbrance: Int {
        min(str, (str + con) / 2)
    }

    @discardableResult
    func addEquipmentItem(
        name: String = "",
        encumbrance: Int = 0,
        notes: String = "",
        isCurrentlyEquipped: Bool = false
    ) -> CharacterEquipmentItem {
        let nextSortOrder = (equipmentItems.map(\.sortOrder).max() ?? -1) + 1
        let item = CharacterEquipmentItem(
            name: name,
            encumbrance: encumbrance,
            notes: notes,
            isCurrentlyEquipped: isCurrentlyEquipped,
            sortOrder: nextSortOrder,
            character: self
        )
        equipmentItems.append(item)
        return item
    }

    @discardableResult
    func addSpell(
        name: String = "",
        points: Int = 0,
        page: String = "",
        kind: SpellKind
    ) -> CharacterSpell {
        let nextSortOrder = (spells.map(\.sortOrder).max() ?? -1) + 1
        let spell = CharacterSpell(
            name: name,
            points: points,
            page: page,
            kind: kind,
            sortOrder: nextSortOrder,
            character: self
        )
        spells.append(spell)
        return spell
    }

    init(name: String = "",
         worships: String = "", reputation: Int = 0, occupation: String = "", sol: String = "", income: Int = 0, ransom: Int = 1000, powExperienceCheck: Bool = false, move: Int = 8,
         maxHitpoints: Int = 1, currentHitpoints: Int = 1, healingRate: Int = 1,
         dateOfBirth: String = "", family: String = "", patron: String = "", portraitData: Data? = nil,
         currentMagicPoints: Int? = nil, runePoints: Int = 3,
         honor: CharacterHonor? = nil, passions: [CharacterPassion] = [], equipmentItems: [CharacterEquipmentItem] = [], spells: [CharacterSpell] = [],
         runeAffinities: [RuneAffinity]? = nil) {
        self.name = name
        
        // TODO these are not real rolls.
        let strRoll = Int.random(in: 3...18) // 3d6
        let conRoll = Int.random(in: 3...18) // 3d6
        let powRoll = Int.random(in: 3...18) // 3d6
        let dexRoll = Int.random(in: 3...18) // 3d6
        let chaRoll = Int.random(in: 3...18) // 3d6
        let intRoll = Int.random(in: 8...18) // 2d6+6
        let sizRoll = Int.random(in: 8...18) // 2d6+6

        self.str = strRoll
        self.con = conRoll
        self.powValue = powRoll
        self.dex = dexRoll
        self.cha = chaRoll
        self.int = intRoll
        self.siz = sizRoll
        let generatedMaxMagicPoints = max(0, powRoll)
        let defaultCurrentMagicPoints = currentMagicPoints ?? generatedMaxMagicPoints
        self.currentMagicPointsValue = min(max(0, defaultCurrentMagicPoints), generatedMaxMagicPoints)
        self.runePointsValue = max(0, runePoints)
        let generatedMaxHitpoints = Self.generatedMaxHitpoints(con: conRoll, siz: sizRoll, pow: powRoll)
        let clampedMaxHitpoints = maxHitpoints == 1 ? generatedMaxHitpoints : max(1, maxHitpoints)
        self.maxHitpoints = clampedMaxHitpoints
        let defaultCurrent = currentHitpoints == 1 ? clampedMaxHitpoints : currentHitpoints
        self.currentHitpoints = min(max(1, defaultCurrent), clampedMaxHitpoints)
        self.healingRate = max(1, healingRate)
        self.move = max(1, move)
        
        self.worships = worships
        self.reputation = reputation.clampedPercentage
        self.occupation = occupation
        self.sol = sol
        self.income = income
        self.ransom = ransom
        self.dateOfBirth = dateOfBirth
        self.family = family
        self.patron = patron
        self.portraitData = portraitData
        self.powExperienceCheck = powExperienceCheck
        self.honor = honor
        self.passions = passions
        self.equipmentItems = equipmentItems
        self.spells = spells
        self.honor?.character = self
        for passion in passions {
            passion.character = self
        }
        for item in equipmentItems {
            item.character = self
        }
        for spell in spells {
            spell.character = self
        }

        syncHitLocationMaximums(preserveDamage: false)
    }

}
