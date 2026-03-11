import Foundation
import Testing
@testable import RQSheet

struct TextImportSectionDetectorTests {
    @Test
    func detectsExpectedSectionsInOrnstal() throws {
        let detected = try TextImportSectionDetector.detect(in: exampleText(named: "Ornstal"))

        #expect(detected.content(for: .characterInfo)?.contains("Name: Ornstal the Quick") == true)
        #expect(detected.content(for: .attributes)?.contains("STR: 12") == true)
        #expect(detected.content(for: .runes)?.contains("Truth | Illusion") == true)
        #expect(detected.content(for: .passions)?.contains("Honor:") == true)
        #expect(detected.content(for: .equipment)?.contains("Armour points show enchanted aluminium armour") == true)
        #expect(detected.content(for: .equipment)?.contains("Rapier") == true)
        #expect(detected.content(for: .skills)?.contains("Agility") == true)
        #expect(detected.content(for: .skills)?.contains("Communication") == true)
        #expect(detected.content(for: .magic)?.contains("Rune Magic") == true)
        #expect(detected.content(for: .magic)?.contains("Spirit Magic") == true)
        #expect(detected.trailingNotes?.contains("Ornstal had a auspicion birth.") == true)
    }

    @Test
    func detectsExpectedSectionsInSelina() throws {
        let detected = try TextImportSectionDetector.detect(in: exampleText(named: "Selina"))

        #expect(detected.content(for: .characterInfo)?.contains("Name: SELINA") == true)
        #expect(detected.content(for: .attributes)?.contains("DEX: 19") == true)
        #expect(detected.content(for: .runes)?.contains("Harmony | Disorder") == true)
        #expect(detected.content(for: .passions)?.contains("Fear the Wild Hunt") == true)
        #expect(detected.content(for: .equipment)?.contains("1H Battle Axe") == true)
        #expect(detected.content(for: .skills)?.contains("COMMUNICATION") == true)
        #expect(detected.content(for: .magic)?.contains("ISSARIES Spells") == true)
        #expect(detected.trailingNotes == nil)
    }

    @Test
    func detectsExpectedSectionsInBeriqet() throws {
        let detected = try TextImportSectionDetector.detect(in: exampleText(named: "Beriqet"))

        #expect(detected.content(for: .characterInfo)?.contains("Name: Beriqet the Wineface") == true)
        #expect(detected.content(for: .runes)?.contains("Wildday: +10") == true)
        #expect(detected.content(for: .passions)?.contains("Fear (the Wild Hunt)") == true)
        #expect(detected.content(for: .equipment)?.contains("Medium Shield") == true)
        #expect(detected.content(for: .skills)?.contains("Ride Mule") == true)
        #expect(detected.content(for: .magic)?.contains("Create Market") == true)
    }

    @Test
    func detectsExpectedSectionsAndBackstoryInDavelia() throws {
        let detected = try TextImportSectionDetector.detect(in: exampleText(named: "Davelia"))

        #expect(detected.content(for: .characterInfo)?.contains("Davelia Sof-Voice") == true)
        #expect(detected.content(for: .attributes)?.contains("STR: 9 INT: 17") == true)
        #expect(detected.content(for: .runes)?.contains("Beast | Man") == true)
        #expect(detected.content(for: .passions)?.contains("Fear (Wolf Pirates)") == true)
        #expect(detected.content(for: .equipment)?.contains("Dagger 8 70%") == true)
        #expect(detected.content(for: .equipment)?.contains("Head 0 AP") == true)
        #expect(detected.content(for: .skills)?.contains("Communication +20%") == true)
        #expect(detected.content(for: .magic)?.contains("Ernalda Spells") == true)
        #expect(detected.trailingNotes?.contains("Backstory:") == true)
        #expect(detected.trailingNotes?.contains("Davelia is the younger daughter") == true)
    }

    private func exampleText(named name: String) throws -> String {
        try TextImportFixtureLoader.text(named: name)
    }
}
