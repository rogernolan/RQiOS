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

    var name: String = ""
    var worships: String = ""

    var str: Int = 0
    var con: Int = 0
    var siz: Int = 0
    var dex: Int = 0
    var int: Int = 0
    private var powValue: Int = 0
    var cha: Int = 0

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

    var damageBonusText: String {
        let total = str + siz

        switch total {
        case ...12:
            return "-1D4"
        case 13...24:
            return "-"
        case 25...32:
            return "+1D4"
        case 33...40:
            return "+1D6"
        case 41...56:
            return "+2D6"
        default:
            return "+\(3 + ((total - 57) / 16))D6"
        }
    }

    private var currentMagicPointsValue: Int = 0
    var currentMagicPoints: Int {
        get { min(max(0, currentMagicPointsValue), maxMagicPoints) }
        set { currentMagicPointsValue = min(max(0, newValue), maxMagicPoints) }
    }

    private var runePointsValue: Int = 3
    var runePoints: Int {
        get { max(0, runePointsValue) }
        set { runePointsValue = max(0, newValue) }
    }
    var maxHitpoints: Int = 1 {
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
    var currentHitpoints: Int = 1 {
        didSet {
            if currentHitpoints < 1 {
                currentHitpoints = 1
            }
            if currentHitpoints > maxHitpoints {
                currentHitpoints = maxHitpoints
            }
        }
    }
    var healingRate: Int = 1 {
        didSet {
            if healingRate < 1 {
                healingRate = 1
            }
        }
    }
    var move: Int? {
        didSet {
            if let move, move < 1 {
                self.move = 1
            }
        }
    }
    
    var reputation: Int = 0 {
        didSet {
            let clamped = reputation.clampedPercentage
            if reputation != clamped {
                reputation = clamped
            }
        }
    }
    var notes: String = ""
    var occupation: String = ""
    var sol: String = ""
    var income: String = ""
    var ransom: Int = 1000
    var dateOfBirth: String = ""
    var family: String = ""
    var patron: String = ""
    var portraitData: Data?
    var powExperienceCheck: Bool = false
    @Relationship(deleteRule: .cascade, inverse: \CharacterHonor.character)
    var honor: CharacterHonor?
    @Relationship(deleteRule: .cascade, originalName: "passions", inverse: \CharacterPassion.character)
    private var storedPassions: [CharacterPassion]? = []
    var passions: [CharacterPassion] {
        get { storedPassions ?? [] }
        set { storedPassions = newValue }
    }
    @Relationship(deleteRule: .cascade, originalName: "equipmentItems", inverse: \CharacterEquipmentItem.character)
    private var storedEquipmentItems: [CharacterEquipmentItem]? = []
    var equipmentItems: [CharacterEquipmentItem] {
        get { storedEquipmentItems ?? [] }
        set { storedEquipmentItems = newValue }
    }
    @Relationship(deleteRule: .cascade, originalName: "spells", inverse: \CharacterSpell.character)
    private var storedSpells: [CharacterSpell]? = []
    var spells: [CharacterSpell] {
        get { storedSpells ?? [] }
        set { storedSpells = newValue }
    }
    @Relationship(deleteRule: .cascade, originalName: "skills", inverse: \CharacterSkill.character)
    private var storedSkills: [CharacterSkill]? = []
    var skills: [CharacterSkill] {
        get { storedSkills ?? [] }
        set { storedSkills = newValue }
    }
    @Relationship(deleteRule: .cascade, originalName: "weapons", inverse: \Weapon.character)
    private var storedWeapons: [Weapon]? = []
    var weapons: [Weapon] {
        get { storedWeapons ?? [] }
        set { storedWeapons = newValue }
    }
    @Relationship(deleteRule: .cascade, originalName: "hitLocations", inverse: \CharacterHitLocation.character)
    private var storedHitLocations: [CharacterHitLocation]? = []
    var hitLocations: [CharacterHitLocation] {
        get { storedHitLocations ?? [] }
        set { storedHitLocations = newValue }
    }
    

    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.fireCharacter)
    var fireAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.darknessCharacter)
    var darknessAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.earthCharacter)
    var earthAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.waterCharacter)
    var waterAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.airCharacter)
    var airAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.moonCharacter)
    var moonAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.manCharacter)
    var manAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.beastCharacter)
    var beastAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.fertilityCharacter)
    var fertilityAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.deathCharacter)
    var deathAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.harmonyCharacter)
    var harmonyAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.disorderCharacter)
    var disorderAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.truthCharacter)
    var truthAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.IllusionCharacter)
    var IllusionAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.stasisCharacter)
    var stasisAffinity: RuneAffinity?
    @Relationship(deleteRule: .cascade, inverse: \RuneAffinity.movementCharacter)
    var movementAffinity: RuneAffinity?
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
        ].compactMap { $0 }
    }

    /// Used only during explicit creation and legacy migration, never during display or cloud import.
    func initializeMissingPairedRunes() {
        if manAffinity == nil && beastAffinity == nil {
            let pair = RuneAffinity.relatedPair(lhName: .man, rhName: .beast)
            manAffinity = pair.0
            beastAffinity = pair.1
        }
        if fertilityAffinity == nil && deathAffinity == nil {
            let pair = RuneAffinity.relatedPair(lhName: .fertility, rhName: .death)
            fertilityAffinity = pair.0
            deathAffinity = pair.1
        }
        if harmonyAffinity == nil && disorderAffinity == nil {
            let pair = RuneAffinity.relatedPair(lhName: .harmony, rhName: .disorder)
            harmonyAffinity = pair.0
            disorderAffinity = pair.1
        }
        if truthAffinity == nil && IllusionAffinity == nil {
            let pair = RuneAffinity.relatedPair(lhName: .truth, rhName: .illusion)
            truthAffinity = pair.0
            IllusionAffinity = pair.1
        }
        if stasisAffinity == nil && movementAffinity == nil {
            let pair = RuneAffinity.relatedPair(lhName: .stasis, rhName: .movement)
            stasisAffinity = pair.0
            movementAffinity = pair.1
        }
    }

    var displayName: String {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? "Unnamed Character" : trimmedName
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
        case .magic:
            return 0
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

    @discardableResult
    func addSkill(name: String, percentage: Int, group: SkillGroup, baseRule: String = "0") -> CharacterSkill {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = trimmedName.isEmpty ? "Unnamed skill" : trimmedName
        let definition = SkillDefinition(
            key: "custom.\(UUID().uuidString.lowercased())",
            name: displayName,
            group: group,
            baseRule: baseRule
        )
        let skill = CharacterSkill(
            character: self,
            definition: definition,
            successPercentage: 0,
            customName: displayName,
            customGroup: group
        )
        skill.setEffectiveValue(percentage)
        skills.append(skill)
        definition.characterSkills.append(skill)
        return skill
    }

    var currentEncumbrance: Int {
        let equipmentTotal = equipmentItems.reduce(into: 0) { total, item in
            if item.isCurrentlyEquipped {
                total += item.encumbrance
            }
        }
        let weaponTotal = weapons.reduce(into: 0) { total, weapon in
            if weapon.isEquipped, let enc = weapon.enc {
                total += enc
            }
        }
        return equipmentTotal + weaponTotal
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
         worships: String = "", reputation: Int = 0, notes: String = "", occupation: String = "", sol: String = "", income: String = "", ransom: Int = 1000, powExperienceCheck: Bool = false, move: Int? = nil,
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
        self.move = move.map { max(1, $0) }
        
        self.worships = worships
        self.reputation = reputation.clampedPercentage
        self.notes = notes
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

        // New records receive the full graph; incoming cloud records are never repaired on reads.
        fireAffinity = RuneAffinity(name: .fire, percentage: 0)
        darknessAffinity = RuneAffinity(name: .darkness, percentage: 0)
        earthAffinity = RuneAffinity(name: .earth, percentage: 0)
        waterAffinity = RuneAffinity(name: .water, percentage: 0)
        airAffinity = RuneAffinity(name: .air, percentage: 0)
        moonAffinity = RuneAffinity(name: .moon, percentage: 0)
        initializeMissingPairedRunes()
        if self.honor == nil { self.honor = CharacterHonor(character: self) }
        syncHitLocationMaximums(preserveDamage: false)
    }

}
