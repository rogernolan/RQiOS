import Foundation
import Testing
@testable import RQSheet

struct TextImportPipelineTests {
    @Test
    func pipelineCombinesParserSlicesForOrnstal() throws {
        let text = try TextImportFixtureLoader.text(named: "Ornstal")

        let result = try TextImportPipeline.parse(text)

        #expect(result.characterInfo.candidateName == "Ornstal the Quick")
        #expect(result.attributes[.pow] == 17)
        #expect(result.runePercentages[.truth] == 75)
        #expect(result.skills.contains(where: { $0.name == "Ride high llama" && $0.isCustom }))
        #expect(result.weapons.contains(where: { $0.name == "Rapier" && $0.percentage == 30 }))
        #expect(result.magic.contains(where: { $0.name == "Analyze Magic" && $0.points == 1 }))
        #expect(result.trailingNotes?.contains("Ornstal had a auspicion birth.") == true)
    }
}
