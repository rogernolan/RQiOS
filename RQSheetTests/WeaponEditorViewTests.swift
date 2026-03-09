import Foundation
import Testing

struct WeaponEditorViewTests {
    @Test
    func weaponEditorSavesBlankCurrentHPAsMaxHPWhenMaxIsPresent() throws {
        let source = try weaponEditorSource()

        #expect(source.contains("if let hpMax"))
        #expect(source.contains("if trimmedCurrentHP.isEmpty"))
        #expect(source.contains("resolvedCurrentHP = hpMax"))
        #expect(source.contains("min(currentHP, hpMax)"))
    }

    private func weaponEditorSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/WeaponEditorView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
