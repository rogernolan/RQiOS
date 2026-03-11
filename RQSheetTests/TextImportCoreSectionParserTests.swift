import Foundation
import Testing
@testable import RQSheet

struct TextImportCoreSectionParserTests {
    @Test
    func parsesOrnstalIdentityAttributesRunesAndPassions() throws {
        let result = try parseExample(named: "Ornstal")

        #expect(result.characterInfo.candidateName == "Ornstal the Quick")
        #expect(result.characterInfo.family == "Lorionaeo")
        #expect(result.characterInfo.patron == "Marele")
        #expect(result.characterInfo.dateOfBirth == "1604 SR")
        #expect(result.characterInfo.occupation == "Scribe")
        #expect(result.characterInfo.reputation == 12)
        #expect(result.characterInfo.sol == "Free")
        #expect(result.characterInfo.income == "120L")
        #expect(result.characterInfo.ransom == 1000)
        #expect(result.characterInfo.cult == "LHANKOR MHY")
        #expect(result.characterInfo.worships.isEmpty)

        #expect(result.attributes[.str] == 12)
        #expect(result.attributes[.con] == 14)
        #expect(result.attributes[.siz] == 16)
        #expect(result.attributes[.dex] == 12)
        #expect(result.attributes[.int] == 14)
        #expect(result.attributes[.pow] == 17)
        #expect(result.attributes[.cha] == 14)

        #expect(result.runePercentages[.fire] == 80)
        #expect(result.runePercentages[.earth] == 70)
        #expect(result.runePercentages[.water] == 30)
        #expect(result.runePercentages[.truth] == 75)
        #expect(result.runePercentages[.illusion] == 25)
        #expect(result.runePercentages[.movement] == 75)
        #expect(result.runePercentages[.stasis] == 25)

        #expect(result.characterInfo.honor == 60)
        #expect(result.passions.contains(where: { $0.name == "Honor" && $0.percentage == 60 }) == false)
        #expect(result.passions.contains(where: { $0.name == "Love (family)" && $0.percentage == 60 }))
        #expect(result.passions.contains(where: { $0.name == "Hate (House Vralaeo)" && $0.percentage == 60 }))
        #expect(result.coverage.foundAttributes == 7)
        #expect(result.coverage.expectedAttributes == 7)
        #expect(result.coverage.foundRunes == 16)
        #expect(result.coverage.expectedRunes == 16)
        #expect(result.coverage.foundPassions == result.passions.count)
    }

    @Test
    func parsesFullOrnstalRuneBlock() throws {
        let result = try parseExample(named: "Ornstal")
        let expectedRunes: [RuneName: Int] = [
            .air: 0,
            .fire: 80,
            .darkness: 0,
            .water: 30,
            .earth: 70,
            .moon: 0,
            .beast: 50,
            .man: 50,
            .fertility: 50,
            .death: 50,
            .harmony: 50,
            .disorder: 50,
            .truth: 75,
            .illusion: 25,
            .stasis: 25,
            .movement: 75,
        ]

        #expect(result.runePercentages.count == expectedRunes.count)

        for (rune, percentage) in expectedRunes {
            #expect(result.runePercentages[rune] == percentage)
        }
    }

    @Test
    func parsesSelinaFirstCultAndAdditionalWorships() throws {
        let result = try parseExample(named: "Selina")

        #expect(result.characterInfo.candidateName == "SELINA")
        #expect(result.characterInfo.family == "LORIONAEO")
        #expect(result.characterInfo.patron == "MARELE")
        #expect(result.characterInfo.originalHouse == "IRNILHA")
        #expect(result.characterInfo.cult == "ISSARIES")
        #expect(result.characterInfo.worships == ["LANBRIL"])
        #expect(result.attributes[.dex] == 19)
        #expect(result.runePercentages[.disorder] == 75)
        #expect(result.runePercentages[.movement] == 85)
        #expect(result.passions.contains(where: { $0.name == "Fear the Wild Hunt" && $0.percentage == 60 }))
    }

    @Test
    func parsesDaveliaWithoutLabeledNameAndCultLine() throws {
        let result = try parseExample(named: "Davelia")

        #expect(result.characterInfo.candidateName == "Davelia Sof-Voice")
        #expect(result.characterInfo.family == "Lorionaeo")
        #expect(result.characterInfo.patron == "Marele")
        #expect(result.characterInfo.dateOfBirth == "1605")
        #expect(result.characterInfo.occupation == "Assistant Priestess")
        #expect(result.characterInfo.cult == "Ernalda (Talosa)")

        #expect(result.attributes[.str] == 9)
        #expect(result.attributes[.int] == 17)
        #expect(result.attributes[.con] == 9)
        #expect(result.attributes[.cha] == 20)

        #expect(result.runePercentages[.earth] == 75)
        #expect(result.runePercentages[.fertility] == 75)
        #expect(result.runePercentages[.death] == 25)
        #expect(result.runePercentages[.disorder] == 60)

        #expect(result.passions.contains(where: { $0.name == "Fear (Death)" && $0.percentage == 60 }))
        #expect(result.passions.contains(where: { $0.name == "Loyalty (House Marele)" && $0.percentage == 80 }))
    }

    private func parseExample(named name: String) throws -> TextImportResult {
        let text = try String(contentsOfFile: "/Users/rog/Desktop/TXT characters/\(name).txt", encoding: .utf8)
        let sections = try TextImportSectionDetector.detect(in: text)
        return TextImportCoreSectionParser.parse(sections)
    }
}
