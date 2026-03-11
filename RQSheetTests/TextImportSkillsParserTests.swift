import Foundation
import Testing
@testable import RQSheet

struct TextImportSkillsParserTests {
    @Test
    func parsesGroupedSkillsAndFlagsCustomVariantsFromOrnstal() throws {
        let result = try parseExample(named: "Ornstal")

        #expect(containsSkill(in: result, name: "Boat", group: "agility", percentage: 10, isCustom: false))
        #expect(containsSkill(in: result, name: "Ride high llama", group: "agility", percentage: 10, isCustom: true))
        #expect(containsSkill(in: result, name: "Speak Esrolian", group: "communication", percentage: 60, isCustom: true))
        #expect(containsSkill(in: result, name: "Meditate", group: "magic", percentage: 0, isCustom: false))
        #expect(result.coverage.foundSkillGroups == 7)
        #expect(result.coverage.expectedSkillGroups == 7)
        #expect(result.coverage.unsupportedSkillGroups == 0)
    }

    @Test
    func skipsPlaceholderSkillRowsButParsesFilledSpecificSkillsFromSelina() throws {
        let result = try parseExample(named: "Selina")

        #expect(containsSkill(in: result, name: "Speak Troll", group: "communication", percentage: 35, isCustom: true))
        #expect(containsSkill(in: result, name: "Worship Issaries", group: "magic", percentage: 50, isCustom: true))
        #expect(containsSkill(in: result, name: "Spirit combat", group: "magic", percentage: 45, isCustom: false))
        #expect(result.skills.contains(where: { $0.name.contains("Ride ____") }) == false)
        #expect(result.skills.contains(where: { $0.name == "Alchemy" }) == false)
        #expect(result.skills.contains(where: { $0.name == "Craft _____" }) == false)
    }

    @Test
    func unsupportedSkillGroupsTurnSkillsSummaryRed() {
        let sections = DetectedTextImportSections(
            sectionContents: [
                .skills: """
                Sorcery +10%
                Read Grimoire 25% [ ]
                """
            ],
            trailingNotes: nil
        )

        let result = TextImportSkillsParser.parse(sections)

        #expect(result.coverage.unsupportedSkillGroups == 1)
        #expect(result.coverage.expectedSkillGroups == 1)
        #expect(result.coverage.foundSkillGroups == 0)
        #expect(result.review().first(where: { $0.section == .skills })?.status == .red)
    }

    private func parseExample(named name: String) throws -> TextImportResult {
        let text = try TextImportFixtureLoader.text(named: name)
        let sections = try TextImportSectionDetector.detect(in: text)
        return TextImportSkillsParser.parse(sections)
    }

    private func containsSkill(
        in result: TextImportResult,
        name: String,
        group: String,
        percentage: Int,
        isCustom: Bool
    ) -> Bool {
        result.skills.contains { skill in
            skill.name == name &&
            skill.groupName == group &&
            skill.percentage == percentage &&
            skill.isCustom == isCustom
        }
    }
}
