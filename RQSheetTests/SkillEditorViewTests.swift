import Foundation
import Testing
@testable import RQSheet

struct SkillEditorViewTests {
    @Test
    func editorDeclaresNameAndPercentageFields() throws {
        let source = try skillEditorSource()

        #expect(source.contains("TextField(\"Skill name\""))
        #expect(source.contains("TextField(\"%\""))
    }

    @Test
    func editorDisablesSaveForEmptyTrimmedNames() throws {
        let source = try skillEditorSource()

        #expect(source.contains("trimmedName.isEmpty"))
        #expect(source.contains(".disabled(trimmedName.isEmpty)"))
    }

    private func skillEditorSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/SkillEditorView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
