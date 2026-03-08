import Foundation
import Testing
@testable import RQSheet

struct SkillsViewTests {
    @Test
    func skillsViewIncludesPerSectionAddButtons() throws {
        let source = try skillsViewSource()

        #expect(source.contains("Add new skill"))
    }

    @Test
    func skillsViewUsesSwipeDeleteWithUndoWarning() throws {
        let source = try skillsViewSource()

        #expect(source.contains(".swipeActions"))
        #expect(source.contains("This cannot be undone"))
        #expect(source.contains("Button(\"Yes\", role: .destructive)"))
        #expect(source.contains("Button(\"No\", role: .cancel)"))
    }

    @Test
    func skillsRowsUseEquipmentStyleMaterialCards() throws {
        let source = try skillsViewSource()

        #expect(source.contains("Color(.systemBackground).opacity(0.52)"))
        #expect(source.contains("RoundedRectangle(cornerRadius: 12)"))
    }

    private func skillsViewSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/SkillsView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
