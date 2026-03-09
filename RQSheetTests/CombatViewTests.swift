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

    @Test
    func combatViewUsesExpandableWeaponCardsAndFloatingAddButton() throws {
        let source = try combatViewSource()

        #expect(source.contains("private func weaponsList(for character: RQCharacter) -> some View {\n        ScrollView {"))
        #expect(source.contains("LazyVStack(spacing: 8)"))
        #expect(source.contains("WeaponRowCard("))
        #expect(source.contains("swipeActions(edge: .trailing, allowsFullSwipe: false)"))
        #expect(source.contains("withAnimation"))
        #expect(source.contains("private var addWeaponButton: some View"))
        #expect(source.contains("Button(\"Add weapon\")"))
        #expect(source.contains(".overlay(alignment: .bottom)"))
        #expect(source.contains(".listStyle(.plain)") == false)
        #expect(source.contains(".environment(\\.defaultMinListRowHeight, 0)") == false)
        #expect(source.contains("This cannot be undone"))
    }

    @Test
    func combatViewDropsWeaponsHeaderAndShowsInlineStrikeRankLabel() throws {
        let source = try combatViewSource()

        #expect(source.contains("private func weaponsSection(for character: RQCharacter) -> some View"))
        #expect(source.contains("return weaponsList(for: character)"))
        #expect(source.contains("Text(\"SR\")"))
        #expect(source.contains(".foregroundStyle(.secondary)"))
        #expect(source.contains("HStack(spacing: 2)"))
        #expect(source.contains("Text(displayStrikeRank)"))
        #expect(source.contains(".frame(width: 40, alignment: .trailing)") == false)
        #expect(source.contains("Text(\"Weapons\")") == false)
        #expect(source.contains("private var weaponsHeaderOverlay") == false)
    }

    @Test
    func combatViewUsesTighterWeaponRowLayoutAndInPlaceExpansionStructure() throws {
        let source = try combatViewSource()

        #expect(source.contains(".padding(.horizontal, 10)"))
        #expect(source.contains("HStack(spacing: 5)"))
        #expect(source.contains(".frame(width: 34, alignment: .trailing)"))
        #expect(source.contains(".frame(width: 22, alignment: .center)"))
        #expect(source.contains(".frame(width: 62, alignment: .trailing)"))
        #expect(source.contains("DisclosureTriangle(isFilled: isExpanded)"))
        #expect(source.contains(".frame(width: 22, height: 22)"))
        #expect(source.contains("List {") == false)
        #expect(source.contains(".listRowInsets(") == false)
        #expect(source.contains(".listRowSeparator(.hidden)") == false)
        #expect(source.contains(".listRowBackground(Color.clear)") == false)
        #expect(source.contains("Image(systemName: isExpanded ? \"triangle.fill\" : \"triangle\")") == false)
        #expect(source.contains(".rotationEffect(.degrees(180))") == false)
        #expect(source.contains(".transition(.move(edge: .top).combined(with: .opacity))") == false)
    }

    @Test
    func combatViewSeparatesDetailHeightAnimationFromDetailFade() throws {
        let source = try combatViewSource()

        #expect(source.contains("private var expandedDetailHeight: CGFloat"))
        #expect(source.contains("@State private var detailOpacity: Double = 0"))
        #expect(source.contains(".frame(height: isExpanded ? expandedDetailHeight : 0, alignment: .top)"))
        #expect(source.contains(".opacity(detailOpacity)"))
        #expect(source.contains(".onChange(of: isExpanded)"))
        #expect(source.contains("scheduleDetailFadeIn()"))
        #expect(source.contains("private let weaponDetailRowHeight: CGFloat = 34"))
        #expect(source.contains("private let weaponDetailVerticalSpacing: CGFloat = 8"))
        #expect(source.contains("private let weaponDetailDividerHeight: CGFloat = 17"))
        #expect(source.contains("private let weaponDetailTopPadding: CGFloat = 16"))
        #expect(source.contains("private let weaponDetailBottomPadding: CGFloat = 8"))
        #expect(source.contains("displayRange == nil"))
        #expect(source.contains("measureHeight") == false)
        #expect(source.contains("detailContent\n                .opacity(detailOpacity)\n                .frame(height: isExpanded ? expandedDetailHeight : 0, alignment: .top)\n                .clipped()"))
        #expect(source.contains(".overlay(alignment: .topLeading) {") == false)
        #expect(source.contains(".animation(.easeInOut(duration: 0.2), value: isExpanded)"))
        #expect(source.contains("private struct DisclosureTriangle: View"))
        #expect(source.contains("TriangleShape()"))
    }

    private func combatViewSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/CombatView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
