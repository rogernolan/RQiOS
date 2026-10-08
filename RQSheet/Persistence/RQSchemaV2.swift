import SwiftData

enum RQSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [RQCharacter.self, RuneAffinity.self, SkillDefinition.self, CharacterSkill.self,
         Weapon.self, CharacterHitLocation.self, CharacterHonor.self, CharacterPassion.self,
         CharacterEquipmentItem.self, CharacterSpell.self]
    }
    static var schema: Schema { Schema(versionedSchema: Self.self) }
}
