import Foundation
import SwiftData

/// Frozen persisted declarations of the unversioned model, verified against every fixture entity hash.
enum RQSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [RQCharacter.self, RuneAffinity.self, SkillDefinition.self, CharacterSkill.self, Weapon.self, CharacterHitLocation.self, CharacterHonor.self, CharacterPassion.self, CharacterEquipmentItem.self, CharacterSpell.self] }
    static var schema: Schema { Schema(versionedSchema: Self.self) }
    @Model
    final class RQCharacter {
        var name: String
        var worships: String
        var str: Int
        var con: Int
        var siz: Int
        var dex: Int
        var int: Int
        private var powValue: Int
        var cha: Int
        private var currentMagicPointsValue: Int
        private var runePointsValue: Int
        var maxHitpoints: Int
        var currentHitpoints: Int
        var healingRate: Int
        var move: Int?
        var reputation: Int
        var notes: String = ""
        var occupation: String
        var sol: String
        var income: String
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
        var weapons: [Weapon] = []
        var hitLocations: [CharacterHitLocation] = []
        var fireAffinity: RuneAffinity = RuneAffinity()
        var darknessAffinity: RuneAffinity = RuneAffinity()
        var earthAffinity: RuneAffinity = RuneAffinity()
        var waterAffinity: RuneAffinity = RuneAffinity()
        var airAffinity: RuneAffinity = RuneAffinity()
        var moonAffinity: RuneAffinity = RuneAffinity()
        var summaryPlaceholderRuneNames: [RuneName]?

        init() {
            self.name = ""
            self.worships = ""
            self.str = 0
            self.con = 0
            self.siz = 0
            self.dex = 0
            self.int = 0
            self.powValue = 0
            self.cha = 0
            self.currentMagicPointsValue = 0
            self.runePointsValue = 0
            self.maxHitpoints = 0
            self.currentHitpoints = 0
            self.healingRate = 0
            self.reputation = 0
            self.occupation = ""
            self.sol = ""
            self.income = ""
            self.ransom = 0
            self.dateOfBirth = ""
            self.family = ""
            self.patron = ""
            self.powExperienceCheck = false
        }
    }

    @Model
    final class RuneAffinity {
        var name: RuneName
        private(set) var percentage: Int  // 0-100
        var experienceCheck: Bool
        var relatedRune: RuneAffinity?

        init() {
            self.name = .fire
            self.percentage = 0
            self.experienceCheck = false
        }
    }

    @Model
    final class SkillDefinition {
        @Attribute(.unique) var key: String
        var name: String
        var group: SkillGroup
        var baseRule: String
        var characterSkills: [CharacterSkill] = []

        init() {
            self.key = ""
            self.name = ""
            self.group = .agility
            self.baseRule = ""
        }
    }

    @Model
    final class CharacterSkill {
        var character: RQCharacter?
        var definition: SkillDefinition?
        private(set) var successPercentage: Int
        var experienceCheck: Bool
        var customName: String
        var customGroup: SkillGroup?

        init() {
            self.successPercentage = 0
            self.experienceCheck = false
            self.customName = ""
        }
    }

    @Model
    final class Weapon {
        var character: RQCharacter?
        var name: String
        var basePercentage: Int
        var experienceCheck: Bool
        var damage: String
        var hpMax: Int?
        var hpCurrent: Int?
        var enc: Int?
        var strikeRank: String
        var type: WeaponType?
        var range: String
        var isEquipped: Bool

        init() {
            self.name = ""
            self.basePercentage = 0
            self.experienceCheck = false
            self.damage = ""
            self.strikeRank = ""
            self.range = ""
            self.isEquipped = false
        }
    }

    @Model
    final class CharacterHitLocation {
        var character: RQCharacter?
        var location: HitLocation
        var maxHP: Int
        var currentHP: Int
        var armour: Int

        init() {
            self.location = .head
            self.maxHP = 0
            self.currentHP = 0
            self.armour = 0
        }
    }

    @Model
    final class CharacterHonor {
        var descriptionText: String
        var percentage: Int
        var experienceCheck: Bool
        var character: RQCharacter?

        init() {
            self.descriptionText = ""
            self.percentage = 0
            self.experienceCheck = false
        }
    }

    @Model
    final class CharacterPassion {
        var descriptionText: String
        var percentage: Int
        var sortOrder: Int
        var character: RQCharacter?

        init() {
            self.descriptionText = ""
            self.percentage = 0
            self.sortOrder = 0
        }
    }

    @Model
    final class CharacterEquipmentItem {
        var name: String
        var encumbrance: Int
        var notes: String
        var isCurrentlyEquipped: Bool
        var sortOrder: Int
        var character: RQCharacter?

        init() {
            self.name = ""
            self.encumbrance = 0
            self.notes = ""
            self.isCurrentlyEquipped = false
            self.sortOrder = 0
        }
    }

    @Model
    final class CharacterSpell {
        var name: String
        var points: Int
        var page: String
        var kindRawValue: String
        var sortOrder: Int
        var character: RQCharacter?

        init() {
            self.name = ""
            self.points = 0
            self.page = ""
            self.kindRawValue = ""
            self.sortOrder = 0
        }
    }
}
