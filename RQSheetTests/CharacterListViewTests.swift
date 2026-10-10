import Foundation
import Testing
@testable import RQSheet

struct CharacterListViewTests {
    @Test(arguments: [(390.0, 1), (679.0, 1), (680.0, 2), (1024.0, 2)])
    func cardColumnsFollowCompactWidthThreshold(width: Double, expectedColumns: Int) {
        #expect(CharacterPickerLayout.columnCount(for: CGFloat(width)) == expectedColumns)
    }

    @Test func primaryGodUsesTheFirstNonEmptyWorshipEntry() {
        #expect(CharacterPickerMetadata.primaryGod(from: "Lhankor Mhy, Orlanth") == "Lhankor Mhy")
        #expect(CharacterPickerMetadata.primaryGod(from: " , Orlanth") == "Orlanth")
        #expect(CharacterPickerMetadata.primaryGod(from: "  ") == nil)
    }

    @Test func emptyOptionalCardMetadataIsHidden() {
        #expect(CharacterPickerMetadata.visibleText(" House of Test ") == "House of Test")
        #expect(CharacterPickerMetadata.visibleText(" \n ") == nil)
    }

    @Test
    func characterCardsUseFourRuneIconsWithoutPercentages() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/CharacterListView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        #expect(source.contains("topSummaryRunes().prefix(4)"))
        #expect(source.contains("character.family"))
        #expect(source.contains("character.persistentModelID"))
        #expect(source.contains("Text(\"\\(rune.percentage)%\")") == false)
    }
}
