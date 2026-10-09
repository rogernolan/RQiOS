import SwiftUI

nonisolated enum IPadCharacterTile: Int, CaseIterable, Identifiable {
    case summary, runes, combat, magic, skills, knowledge, equipment, notes

    var id: Int { rawValue }
    var title: String {
        switch self {
        case .summary: "Summary"
        case .runes: "Runes"
        case .combat: "Combat"
        case .magic: "Magic"
        case .skills: "Skills"
        case .knowledge: "Knowledge"
        case .equipment: "Equipment"
        case .notes: "Notes"
        }
    }
    var identifier: String { title.lowercased() }
    var runeName: String {
        switch self {
        case .summary: "RuneMan"
        case .runes: "RuneInfinity"
        case .combat: "RuneDeath"
        case .magic: "RuneMagic"
        case .skills, .knowledge: "RuneMastery"
        case .equipment: "RuneTrade"
        case .notes: "RuneTruth"
        }
    }
    var skillGroups: [SkillGroup] {
        switch self {
        case .skills: [.agility, .communication, .manipulation, .magic, .perception, .stealth]
        case .knowledge: [.knowledge]
        default: []
        }
    }
}

nonisolated struct IPadTileArrangement {
    let usesPhoneLayout: Bool
    let columnCount: Int
    let rows: [[IPadCharacterTile]]

    init(width: CGFloat, height: CGFloat) {
        usesPhoneLayout = width < 680
        columnCount = width > height ? 3 : 2
        rows = width > height
            ? [[.summary, .runes, .magic], [.combat, .skills, .knowledge], [.equipment, .notes]]
            : [[.summary, .runes], [.combat, .magic], [.skills, .knowledge], [.equipment, .notes]]
    }
}

/// Placement changes while the canonical ForEach identities stay mounted.
struct IPadTileLayout: Layout {
    let arrangement: IPadTileArrangement
    var spacing: CGFloat = 16

    private func columnWidth(_ width: CGFloat) -> CGFloat {
        max(1, (width - spacing * CGFloat(arrangement.columnCount - 1)) / CGFloat(arrangement.columnCount))
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 1024
        let tileWidth = columnWidth(width)
        let heights = arrangement.rows.map { row in
            row.map { tile in
                subviews[tile.rawValue].sizeThatFits(ProposedViewSize(width: tileWidth, height: nil)).height
            }.max() ?? 0
        }
        return CGSize(width: width, height: heights.reduce(0, +) + spacing * CGFloat(max(0, heights.count - 1)))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let tileWidth = columnWidth(bounds.width)
        var y = bounds.minY
        for row in arrangement.rows {
            var rowHeight: CGFloat = 0
            for (column, tile) in row.enumerated() {
                let view = subviews[tile.rawValue]
                let size = view.sizeThatFits(ProposedViewSize(width: tileWidth, height: nil))
                view.place(at: CGPoint(x: bounds.minX + CGFloat(column) * (tileWidth + spacing), y: y), anchor: .topLeading,
                           proposal: ProposedViewSize(width: tileWidth, height: size.height))
                rowHeight = max(rowHeight, size.height)
            }
            y += rowHeight + spacing
        }
    }
}
