import Foundation
import Testing
@testable import RQSheet

struct SkillsViewTests {
    @Test
    func skillsViewIncludesPerSectionFooterAddButtons() throws {
        let source = try skillsViewSource()

        #expect(source.contains("Add new skill"))
        #expect(source.contains("} footer: {"))
        #expect(source.contains("private func addSkillRow(for group: SkillGroup)"))
        #expect(source.contains(".padding(.bottom, 12)"))
        #expect(source.contains(".accessibilityIdentifier(\"skills.add.\\(group.rawValue)\")"))
        #expect(source.contains("private func groupHeader(for group: SkillGroup) -> some View"))
        #expect(source.contains(".font(.headline)"))
    }

    @Test
    func skillsViewIncludesMagicGroupTitle() throws {
        let source = try skillsViewSource()

        #expect(source.contains("case .magic:"))
        #expect(source.contains("return \"Magic\""))
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

    @Test
    func skillRowsMakeWholeCardTappableExceptCheckbox() throws {
        let source = try skillsViewSource()

        #expect(source.contains(".contentShape(Rectangle())"))
        #expect(source.contains(".frame(maxWidth: .infinity, alignment: .leading)"))
        #expect(source.contains("Spacer(minLength: 8)"))
        #expect(source.contains("Button(action: onSelect)"))
        #expect(source.contains("Button {"))
    }

    private func skillsViewSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/SkillsView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
