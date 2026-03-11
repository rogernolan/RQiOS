import Foundation
import SwiftData
import Testing
@testable import RQSheet

struct TextImportApplierTests {
    @Test
    @MainActor
    func applierCreatesNewCharacterFromParsedImportResult() throws {
        let schema = Schema([
            RQCharacter.self,
            CharacterEquipmentItem.self,
            CharacterSpell.self,
            RuneAffinity.self,
            SkillDefinition.self,
            CharacterSkill.self,
            Weapon.self,
            CharacterHitLocation.self,
            CharacterHonor.self,
            CharacterPassion.self,
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let text = try TextImportFixtureLoader.text(named: "Ornstal")
        let result = try TextImportPipeline.parse(text)

        let character = try TextImportApplier.apply(result: result, nameOverride: "Imported Ornstal", in: context)

        #expect(character.name == "Imported Ornstal")
        #expect(character.family == "Lorionaeo")
        #expect(character.patron == "Marele")
        #expect(character.occupation == "Scribe")
        #expect(character.worships.contains("LHANKOR MHY"))
        #expect(character.pow == 17)
        #expect(character.truthAffinity.percentage == 75)
        #expect(character.ensureHonorExists().percentage == 60)
        #expect(character.passions.contains(where: { $0.descriptionText == "Honor" && $0.percentage == 60 }) == false)
        #expect(character.skills.contains(where: { $0.displayName == "Ride high llama" }))
        #expect(character.weapons.contains(where: { $0.name == "Rapier" && $0.basePercentage == 30 }))
        #expect(character.spells.contains(where: { $0.name == "Analyze Magic" && $0.points == 1 }))
        #expect(character.equipmentItems.contains(where: { $0.name.contains("Writing implements") }))
        #expect(character.notes.contains("Ornstal had a auspicion birth."))
    }
}
