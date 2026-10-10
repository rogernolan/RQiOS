import SwiftData
import SwiftUI

struct IPadCharacterTilesView: View {
    let character: RQCharacter
    let windowSize: CGSize
    let keyboardInset: CGFloat

    private var skillGroups: (first: [SkillGroup], second: [SkillGroup]) {
        let counts = character.skills.reduce(into: [SkillGroup: Int]()) { result, skill in
            guard let group = skill.resolvedGroup else { return }
            result[group, default: 0] += 1
        }
        return IPadSkillGroupPartition.split(skillCounts: counts)
    }

    var body: some View {
        let arrangement = IPadTileArrangement(width: windowSize.width, height: windowSize.height)
        let tileWidth = max(1, (windowSize.width - 32 - CGFloat(arrangement.columnCount - 1) * 16) / CGFloat(arrangement.columnCount))
        let groups = skillGroups
        ScrollViewReader { proxy in
            ScrollView {
                IPadTileLayout(order: arrangement.order, columnCount: arrangement.columnCount) {
                    ForEach(arrangement.order) { tile in
                        tileView(tile, groups: groups)
                            .environment(\.characterSectionPresentation, .tile(width: tileWidth - 24))
                            .environment(\.characterSectionScrollToEditor, { anchor in
                                withAnimation(.easeInOut(duration: 0.2)) { proxy.scrollTo(anchor, anchor: .center) }
                            })
                            .id(tile)
                    }
                }
                .padding(16)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: keyboardInset) }
            .scrollDismissesKeyboard(.interactively)
            .accessibilityIdentifier("workspace.tiles")
        }
    }

    private func tileView(_ tile: IPadCharacterTile, groups: (first: [SkillGroup], second: [SkillGroup])) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(tile.title)
                    .accessibilityIdentifier("tile.\(tile.identifier).title")
            } icon: {
                Image(tile.runeName).resizable().renderingMode(.template).scaledToFit().frame(width: 22, height: 22)
            }
            .font(.title3.weight(.semibold))
            sectionContent(tile, groups: groups)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground).opacity(0.85))
                .overlay(alignment: .topTrailing) {
                    Image(tile.runeName).resizable().renderingMode(.template).scaledToFit()
                        .frame(width: 180, height: 180)
                        .foregroundStyle(Color(red: 0.78, green: 0.73, blue: 0.64).opacity(0.12))
                        .padding(12)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .overlay { RoundedRectangle(cornerRadius: 20).stroke(.quaternary, lineWidth: 1) }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tile.\(tile.identifier)")
    }

    @ViewBuilder private func sectionContent(_ tile: IPadCharacterTile, groups: (first: [SkillGroup], second: [SkillGroup])) -> some View {
        switch tile {
        case .summary: StatsOverviewView(character: character)
        case .runes: RunesView(character: character)
        case .combat: CombatView(character: character)
        case .magic: MagicView(character: character)
        case .skills1: SkillsView(character: character, groups: groups.first, searchAccessibilityIdentifier: "skills1.search")
        case .skills2: SkillsView(character: character, groups: groups.second, searchAccessibilityIdentifier: "skills2.search")
        case .equipment: EquipmentView(character: character)
        case .notes: NotesView(character: character)
        }
    }
}
