import Foundation
import Testing
@testable import RQSheet

struct TextImportEquipmentAndMagicParserTests {
    @Test
    func parsesOrnstalWeaponsEquipmentMagicAndTrailingNotes() throws {
        let result = try parseExample(named: "Ornstal")

        let hasRapier = result.weapons.contains(where: {
            $0.name == "Rapier" && $0.percentage == 30 && $0.damage == "1d6+1"
        })
        let hasSelfBow = result.weapons.contains(where: {
            $0.name == "Self Bow" && $0.range == "80"
        })
        let hasAnalyzeMagic = result.magic.contains(where: {
            $0.name == "Analyze Magic" && $0.points == 1 && $0.source.contains("Lankhor Mhy Spells")
        })
        let hasCommandCultSpirit = result.magic.contains(where: {
            $0.name == "Command Cult Spirit" && $0.points == 2
        })
        let hasDetectMagic = result.magic.contains(where: {
            $0.name == "Detect Magic" && $0.points == 1 && $0.source.contains("Spells in Mind")
        })

        #expect(hasRapier)
        #expect(hasSelfBow)
        #expect(result.equipment.contains("Writing implements and materials (with small wooden carrying case)"))
        #expect(result.equipment.contains("A short suit of enchanted aluminium plate and open helmet."))
        #expect(hasAnalyzeMagic)
        #expect(hasCommandCultSpirit)
        #expect(hasDetectMagic)

        #expect(result.trailingNotes?.contains("Ornstal had a auspicion birth.") == true)
        #expect(result.coverage.foundEquipmentEntries > 0)
        #expect(result.coverage.foundMagicEntries > 0)
    }

    @Test
    func parsesDaveliaMagicLinesAndBackstory() throws {
        let result = try parseExample(named: "Davelia")

        let hasDagger = result.weapons.contains(where: { $0.name == "Dagger" && $0.percentage == 70 })
        let hasCallSnakes = result.magic.contains(where: { $0.name == "Call Snakes" && $0.points == 1 })
        let hasControlSnakes = result.magic.contains(where: { $0.name == "Control Snakes" && $0.points == 1 })

        #expect(hasDagger)
        #expect(hasCallSnakes)
        #expect(hasControlSnakes)
        #expect(result.trailingNotes?.contains("Backstory:") == true)
        #expect(result.trailingNotes?.contains("Davelia is the younger daughter") == true)
    }

    @Test
    func emptySectionsYieldYellowEquipmentAndMagicSummary() {
        let result = TextImportEquipmentAndMagicParser.parse(
            DetectedTextImportSections(sectionContents: [:], trailingNotes: nil)
        )
        let review = result.review()
        let equipmentStatus = review.first(where: { $0.section == .equipment })?.status
        let magicStatus = review.first(where: { $0.section == .magic })?.status

        #expect(equipmentStatus == .yellow)
        #expect(magicStatus == .yellow)
    }

    private func parseExample(named name: String) throws -> TextImportResult {
        let text = try String(contentsOfFile: "/Users/rog/Desktop/TXT characters/\(name).txt", encoding: .utf8)
        let sections = try TextImportSectionDetector.detect(in: text)
        return TextImportEquipmentAndMagicParser.parse(sections)
    }
}
