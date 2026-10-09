import SwiftUI

nonisolated enum IPadCharacterTile: Int, CaseIterable, Identifiable, Hashable {
    case summary, runes, combat, magic, skills1, skills2, equipment, notes

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .summary: "Summary"
        case .runes: "Runes"
        case .combat: "Combat"
        case .magic: "Magic"
        case .skills1: "Skills 1"
        case .skills2: "Skills 2"
        case .equipment: "Equipment"
        case .notes: "Notes"
        }
    }

    var identifier: String { title.lowercased().replacingOccurrences(of: " ", with: "") }

    var runeName: String {
        switch self {
        case .summary: "RuneMan"
        case .runes: "RuneInfinity"
        case .combat: "RuneDeath"
        case .magic: "RuneMagic"
        case .skills1, .skills2: "RuneMastery"
        case .equipment: "RuneTrade"
        case .notes: "RuneTruth"
        }
    }
}

nonisolated struct IPadTileArrangement {
    static let portraitOrder: [IPadCharacterTile] = [.summary, .runes, .combat, .magic, .skills1, .skills2, .equipment, .notes]
    static let landscapeOrder: [IPadCharacterTile] = [.summary, .runes, .magic, .combat, .skills1, .skills2, .equipment, .notes]

    let usesPhoneLayout: Bool
    let columnCount: Int
    let order: [IPadCharacterTile]

    init(width: CGFloat, height: CGFloat) {
        usesPhoneLayout = width < 680
        columnCount = width > height ? 3 : 2
        order = width > height ? Self.landscapeOrder : Self.portraitOrder
    }
}

nonisolated enum IPadColumnPartition {
    static func partition(heights: [CGFloat], columnCount: Int) -> [Range<Int>] {
        guard !heights.isEmpty else { return [] }

        let count = min(max(columnCount, 1), heights.count)
        var bestRanges: [Range<Int>] = []
        var bestDifference = CGFloat.infinity

        func search(start: Int, ranges: [Range<Int>]) {
            let remainingColumns = count - ranges.count
            if remainingColumns == 1 {
                let finalRange = start..<heights.count
                let candidate = ranges + [finalRange]
                let totals = candidate.map { range in
                    range.reduce(CGFloat.zero) { $0 + heights[$1] }
                }
                let difference = (totals.max() ?? 0) - (totals.min() ?? 0)
                if difference < bestDifference {
                    bestDifference = difference
                    bestRanges = candidate
                }
                return
            }

            let latestEnd = heights.count - remainingColumns + 1
            guard start < latestEnd else { return }
            for end in (start + 1)...latestEnd {
                search(start: end, ranges: ranges + [start..<end])
            }
        }

        search(start: 0, ranges: [])
        return bestRanges
    }
}

nonisolated enum IPadSkillGroupPartition {
    private static let rowHeight: CGFloat = 44
    private static let headingHeight: CGFloat = 38
    private static let addControlHeight: CGFloat = 48

    static func split(skillCounts: [SkillGroup: Int]) -> (first: [SkillGroup], second: [SkillGroup]) {
        let groups = SkillGroup.allCases
        var bestBoundary = 1
        var bestDifference = CGFloat.infinity

        for boundary in 1..<groups.count {
            let firstHeight = estimatedHeight(for: groups[..<boundary], skillCounts: skillCounts)
            let secondHeight = estimatedHeight(for: groups[boundary...], skillCounts: skillCounts)
            let difference = abs(firstHeight - secondHeight)
            if difference < bestDifference {
                bestDifference = difference
                bestBoundary = boundary
            }
        }

        return (Array(groups[..<bestBoundary]), Array(groups[bestBoundary...]))
    }

    private static func estimatedHeight(for groups: ArraySlice<SkillGroup>, skillCounts: [SkillGroup: Int]) -> CGFloat {
        groups.reduce(CGFloat.zero) { total, group in
            let count = max(0, skillCounts[group, default: 0])
            return total + CGFloat(count) * rowHeight + headingHeight + addControlHeight
        }
    }
}

/// Places ordered tiles in contiguous top-to-bottom columns whose measured heights are balanced.
struct IPadTileLayout: Layout {
    let order: [IPadCharacterTile]
    let columnCount: Int
    var spacing: CGFloat = 16

    private func columnWidth(_ width: CGFloat) -> CGFloat {
        max(1, (width - spacing * CGFloat(columnCount - 1)) / CGFloat(columnCount))
    }

    private func measuredHeights(tileWidth: CGFloat, subviews: Subviews) -> [CGFloat] {
        order.indices.map { index in
            subviews[index].sizeThatFits(ProposedViewSize(width: tileWidth, height: nil)).height
        }
    }

    private func ranges(for heights: [CGFloat]) -> [Range<Int>] {
        IPadColumnPartition.partition(heights: heights, columnCount: columnCount)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 1024
        let tileWidth = columnWidth(width)
        let heights = measuredHeights(tileWidth: tileWidth, subviews: subviews)
        let columnHeights = ranges(for: heights).map { range in
            range.reduce(CGFloat.zero) { total, index in total + heights[index] }
                + spacing * CGFloat(max(0, range.count - 1))
        }
        return CGSize(width: width, height: columnHeights.max() ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let tileWidth = columnWidth(bounds.width)
        let heights = measuredHeights(tileWidth: tileWidth, subviews: subviews)
        let columns = ranges(for: heights)

        for (columnIndex, range) in columns.enumerated() {
            let x = bounds.minX + CGFloat(columnIndex) * (tileWidth + spacing)
            var y = bounds.minY
            for index in range {
                let size = subviews[index].sizeThatFits(ProposedViewSize(width: tileWidth, height: nil))
                subviews[index].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: tileWidth, height: size.height)
                )
                y += size.height + spacing
            }
        }
    }
}
