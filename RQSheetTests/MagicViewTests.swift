import CoreGraphics
import SwiftUI
import Testing
@testable import RQSheet

struct MagicViewTests {
    @Test
    func magicViewConfigExposesSearchAndSectionTitles() {
        #expect(MagicViewConfiguration.searchPlaceholder == "Search magic")
        #expect(MagicViewConfiguration.sectionTitles == ["Spirit Magic", "Rune Spells", "Common Rune Spells"])
        #expect(MagicViewConfiguration.deleteConfirmationTitle == "This cannot be undone")
    }

    @Test
    func magicViewConfigExposesScrollAnchorAndChipWidths() {
        #expect(MagicViewConfiguration.editorScrollAnchor == UnitPoint(x: 0.5, y: 0.16))
        #expect(MagicViewConfiguration.magicPointsMinWidth == CGFloat(108))
        #expect(MagicViewConfiguration.runePointsMinWidth == CGFloat(74))
    }

    @Test
    func magicViewFormatsFallbackAndTrimmedPages() {
        #expect(MagicViewConfiguration.displayPage(for: "") == "p-")
        #expect(MagicViewConfiguration.displayPage(for: "  ") == "p-")
        #expect(MagicViewConfiguration.displayPage(for: "323") == "p323")
        #expect(MagicViewConfiguration.displayPage(for: " 328 ") == "p328")
    }
}
