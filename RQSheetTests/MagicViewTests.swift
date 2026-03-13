import Foundation
import Testing
@testable import RQSheet

struct MagicViewTests {
    @Test
    func magicViewIsNoLongerAPlaceholder() throws {
        let source = try magicViewSource()

        #expect(source.contains("Magic placeholder") == false)
        #expect(source.contains("Text(\"Create a character in Summary to manage magic.\")") == false)
        #expect(source.contains("CharacterMagicContentView(character: character)"))
    }

    @Test
    func magicViewDoesNotDeclareItsOwnNavigationStack() throws {
        let source = try magicViewSource()

        #expect(source.contains("NavigationStack {") == false)
    }

    @Test
    func magicViewContainsSearchAndSectionTitles() throws {
        let source = try magicViewSource()

        #expect(source.contains("TextField(\"Search magic\""))
        #expect(source.contains("title: \"Spirit Magic\""))
        #expect(source.contains("title: \"Rune Spells\""))
        #expect(source.contains("title: \"Common Rune Spells\""))
    }

    @Test
    func magicViewContainsAddButtonsBelowListsAndDeleteConfirmation() throws {
        let source = try magicViewSource()

        #expect(source.contains("private var spiritAddButtonRow"))
        #expect(source.contains("private var runeAddButtonRow"))
        #expect(source.contains(".alert(\"This cannot be undone\""))
    }

    @Test
    func magicViewUsesCompactSpellRowsAndRpLabel() throws {
        let source = try magicViewSource()

        #expect(source.contains("Text(\"RP\")"))
        #expect(source.contains("return trimmed.isEmpty ? \"p-\" : \"p\\(trimmed)\""))
        #expect(source.contains("Text(pointsText)"))
    }

    @Test
    func magicViewUsesSharedEditableChipForMpAndRp() throws {
        let source = try magicViewSource()

        #expect(source.contains("EditableChipValue("))
        #expect(source.contains("mode: .currentOfMax"))
        #expect(source.contains("readOnlySuffix: \"/ \\(maxPoints)\""))
        #expect(source.contains("mode: .singleValue"))
        #expect(source.contains("private struct MagicPointsEditor: View"))
        #expect(source.contains("private struct RunePointsEditor: View"))
        #expect(source.contains(".frame(minWidth: 108)") || source.contains(".frame(width: 108)"))
        #expect(source.contains(".frame(minWidth: 74)") || source.contains(".frame(width: 74)"))
    }

    @Test
    func magicViewScrollsEditorsBelowSearchHeaderInsteadOfToListTop() throws {
        let source = try magicViewSource()

        #expect(source.contains("private let editorScrollAnchor = UnitPoint(x: 0.5, y: 0.16)"))
        #expect(source.contains("proxy.scrollTo(newAnchor, anchor: editorScrollAnchor)"))
        #expect(source.contains("proxy.scrollTo(newAnchor, anchor: .top)") == false)
    }

    private func magicViewSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/MagicView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
