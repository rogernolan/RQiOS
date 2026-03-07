import Foundation
import SwiftUI
import Testing
@testable import RQSheet

struct EquipmentEditorViewTests {
    @Test
    @MainActor
    func editorCanBeCreatedForAnEquipmentItem() {
        let item = CharacterEquipmentItem(
            name: "Shield",
            encumbrance: 2,
            notes: "Bronze",
            isCurrentlyEquipped: true
        )

        let view = EquipmentEditorView(item: item)

        _ = view.body
        #expect(item.name == "Shield")
        #expect(item.encumbrance == 2)
        #expect(item.notes == "Bronze")
    }

    @Test
    func editorUsesScrollLayoutInsteadOfForm() throws {
        let source = try equipmentEditorSource()

        #expect(source.contains("Form {") == false)
    }

    @Test
    func editorUsesTextEditorForNotes() throws {
        let source = try equipmentEditorSource()

        #expect(source.contains("TextEditor(text: $item.notes)"))
        #expect(source.contains("TextField(\"Description / Notes\"") == false)
    }

    private func equipmentEditorSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/EquipmentEditorView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
