import Foundation
import Testing
@testable import RQSheet

struct SpellEditorViewTests {
    @Test
    @MainActor
    func editorCanBeCreatedWithInitialValues() {
        let view = SpellEditorView(
            title: "Edit Rune Spell",
            name: "Shield",
            points: 2,
            page: "67"
        ) { _, _, _ in }

        _ = view.body
    }

    @Test
    func editorUsesNavigationStackAndForm() throws {
        let source = try spellEditorSource()

        #expect(source.contains("NavigationStack {"))
        #expect(source.contains("Form {"))
    }

    @Test
    func editorContainsNamePointsAndPageFields() throws {
        let source = try spellEditorSource()

        #expect(source.contains("LabeledContent(\"Name\")"))
        #expect(source.contains("LabeledContent(\"Points\")"))
        #expect(source.contains("LabeledContent(\"Page\")"))
    }

    @Test
    func editorHasExplicitCancelAndSaveToolbar() throws {
        let source = try spellEditorSource()

        #expect(source.contains("ToolbarItem(placement: .cancellationAction)"))
        #expect(source.contains("ToolbarItem(placement: .confirmationAction)"))
        #expect(source.contains("Button(\"Save\")"))
    }

    private func spellEditorSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/SpellEditorView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
