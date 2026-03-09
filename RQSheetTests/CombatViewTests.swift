import Foundation
import Testing
@testable import RQSheet

struct CombatViewTests {
    @Test
    func combatViewFormatsOptionalWeaponFieldsForDisplay() throws {
        let source = try combatViewSource()

        #expect(source.contains("private func weaponHPText(for weapon: Weapon) -> String"))
        #expect(source.contains("guard let hpMax = weapon.hpMax, let hpCurrent = weapon.hpCurrent else { return \"-\" }"))
        #expect(source.contains("private func weaponStrikeRankText(for weapon: Weapon) -> String"))
        #expect(source.contains("return weapon.strikeRank.isEmpty ? \"-\" : weapon.strikeRank"))
    }

    @Test
    func combatViewKeepsStrikeRankAsTextAndBlankOptionalsAsNil() throws {
        let source = try combatViewSource()

        #expect(source.contains(".sheet(item: $presentedEditor)"))
        #expect(source.contains("WeaponEditorView("))
        #expect(source.contains("presentedEditor = .add"))
        #expect(source.contains("presentedEditor = .edit("))
    }

    private func combatViewSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/CombatView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
