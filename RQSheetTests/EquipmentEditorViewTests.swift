import Foundation
import SwiftUI
import Testing
@testable import RQSheet

struct EquipmentEditorViewTests {
    @Test
    @MainActor
    func editorCanBeCreatedWithInitialValues() {
        let view = EquipmentEditorView(
            title: "Edit Equipment",
            name: "Shield",
            encumbrance: 2,
            notes: "Bronze"
        ) { _, _, _ in }

        _ = view.body
    }

    @Test
    func editorUsesNavigationStackAndForm() throws {
        let source = try equipmentEditorSource()

        #expect(source.contains("NavigationStack {"))
        #expect(source.contains("Form {"))
    }

    @Test
    func editorUsesTextEditorForNotes() throws {
        let source = try equipmentEditorSource()

        #expect(source.contains("Section(\"Description / Notes\")"))
        #expect(source.contains("TextEditor(text: $notes)"))
    }

    @Test
    func editorHasExplicitCancelAndSaveToolbar() throws {
        let source = try equipmentEditorSource()

        #expect(source.contains("ToolbarItem(placement: .cancellationAction)"))
        #expect(source.contains("ToolbarItem(placement: .confirmationAction)"))
        #expect(source.contains("Button(\"Save\")"))
    }

    private func equipmentEditorSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/EquipmentEditorView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
