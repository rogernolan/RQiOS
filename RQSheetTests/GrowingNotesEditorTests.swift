import SwiftUI
import Testing
import UIKit
@testable import RQSheet

@MainActor
struct GrowingNotesEditorTests {
    @Test func emptyEditorHasMinimumHeightAndDoesNotScroll() {
        let view = GrowingNotesTextView(frame: CGRect(x: 0, y: 0, width: 300, height: 180), textContainer: nil)
        #expect(view.isScrollEnabled == false)
        #expect(view.intrinsicContentSize.height == 180)
        #expect(view.adjustsFontForContentSizeCategory)
        #expect(view.accessibilityIdentifier == "notes.editor")
    }

    @Test func fullNoteExpandsAndReflowsAtItsActualWidth() {
        let view = GrowingNotesTextView(frame: CGRect(x: 0, y: 0, width: 300, height: 180), textContainer: nil)
        view.text = Array(repeating: "A long note with enough text to wrap at the tile width.", count: 60).joined(separator: "\n")
        let narrowHeight = view.intrinsicContentSize.height
        #expect(narrowHeight > 180)
        view.bounds.size.width = 600
        view.layoutIfNeeded()
        let wideHeight = view.intrinsicContentSize.height
        #expect(wideHeight < narrowHeight)
        #expect(wideHeight > 180)
        #expect(view.isScrollEnabled == false)
    }

    @Test func unchangedTextPreservesCaretAndSelectionAcrossUpdates() {
        let view = GrowingNotesTextView()
        view.text = "Note about Ornstal"
        view.selectedRange = NSRange(location: 5, length: 5)
        view.replaceTextPreservingSelection("Note about Ornstal")
        #expect(view.selectedRange == NSRange(location: 5, length: 5))
        view.replaceTextPreservingSelection("Note about Ornstal and Voraneva")
        #expect(view.selectedRange == NSRange(location: 5, length: 5))
    }

    @Test func externalShorteningClampsSelectionUsingUTF16Offsets() {
        let view = GrowingNotesTextView()
        view.text = "A long note"
        view.selectedRange = NSRange(location: 4, length: 5)
        view.replaceTextPreservingSelection("A 🐉")
        #expect(view.selectedRange == NSRange(location: 4, length: 0))
        view.replaceTextPreservingSelection("")
        #expect(view.selectedRange == NSRange(location: 0, length: 0))
        #expect(view.text.isEmpty)
    }
}
