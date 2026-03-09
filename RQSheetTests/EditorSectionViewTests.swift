import Foundation
import Testing
@testable import RQSheet

struct EditorSectionViewTests {
    @Test
    func combatSectionUsesTextBindingForOptionalMove() throws {
        let source = try editorSource(named: "EditorCombatAndDerivedSectionView.swift")

        #expect(source.contains("EditorTextFieldRow("))
        #expect(source.contains("label: \"Move\""))
        #expect(source.contains("get: { viewModel.character.move.map(String.init) ?? \"\" }"))
        #expect(source.contains("set: { newValue in"))
    }

    @Test
    func economySectionUsesPlainIncomeLabelAndTextBinding() throws {
        let source = try editorSource(named: "EditorEconomySectionView.swift")

        #expect(source.contains("EditorTextFieldRow("))
        #expect(source.contains("label: \"Income\""))
        #expect(source.contains("label: \"Income (L)\"") == false)
        #expect(source.contains("get: { viewModel.character.income }"))
    }

    private func editorSource(named fileName: String) throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/Editor")
            .appendingPathComponent(fileName)

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
