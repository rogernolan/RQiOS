import Foundation
import Testing
@testable import RQSheet

struct TextImportSkillsParserTests {
    @Test
    func parsesGroupedSkillsAndFlagsCustomVariantsFromOrnstal() throws {
        let result = try parseExample(named: "Ornstal")

        #expect(result.skills.contains(where: {
            $0.name == "Boat" && $0.groupName == "agility" && $0.percentage == 10 && $0.isCustom == false
        }))
        #expect(result.skills.contains(where: {
            $0.name == "Ride high llama" && $0.groupName == "agility" && $0.percentage == 10 && $0.isCustom
        }))
        #expect(result.skills.contains(where: {
            $0.name == "Speak Esrolian" && $0.groupName == "communication" && $0.percentage == 60 && $0.isCustom
        }))
        #expect(result.skills.contains(where: {
            $0.name == "Meditate" && $0.groupName == "magic" && $0.percentage == 0 && $0.isCustom == false
        }))
        #expect(result.coverage.foundSkillGroups == 7)
        #expect(result.coverage.expectedSkillGroups == 7)
        #expect(result.coverage.unsupportedSkillGroups == 0)
    }

    @Test
    func skipsPlaceholderSkillRowsButParsesFilledSpecificSkillsFromSelina() throws {
        let result = try parseExample(named: "Selina")

        #expect(result.skills.contains(where: {
            $0.name == "Speak Troll" && $0.groupName == "communication" && $0.percentage == 35 && $0.isCustom
        }))
        #expect(result.skills.contains(where: {
            $0.name == "Worship Issaries" && $0.groupName == "magic" && $0.percentage == 50 && $0.isCustom
        }))
        #expect(result.skills.contains(where: {
            $0.name == "Spirit combat" && $0.groupName == "magic" && $0.percentage == 45 && $0.isCustom == false
        }))
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
        let text = try String(contentsOfFile: "/Users/rog/Desktop/TXT characters/\(name).txt", encoding: .utf8)
        let sections = try TextImportSectionDetector.detect(in: text)
        return TextImportSkillsParser.parse(sections)
    }
}
