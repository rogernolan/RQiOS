import SwiftData

enum RQMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [RQSchemaV1.self, RQSchemaV2.self] }
    static var stages: [MigrationStage] {
        [.custom(fromVersion: RQSchemaV1.self, toVersion: RQSchemaV2.self, willMigrate: nil, didMigrate: { context in
            // The original tuple declarations were not persisted by SwiftData. Only this
            // upgrade initializes those missing slots; partial cloud records stay partial.
            for character in try context.fetch(FetchDescriptor<RQCharacter>()) {
                // The old six slots had no rune-owner inverse columns. Populate
                // those new links from the existing unambiguous character slots.
                character.fireAffinity?.fireCharacter = character
                character.darknessAffinity?.darknessCharacter = character
                character.earthAffinity?.earthCharacter = character
                character.waterAffinity?.waterCharacter = character
                character.airAffinity?.airCharacter = character
                character.moonAffinity?.moonCharacter = character
                character.initializeMissingPairedRunes()
            }
            try context.save()
        })]
    }
}
