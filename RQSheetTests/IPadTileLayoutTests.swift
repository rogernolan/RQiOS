import Foundation
import Testing
@testable import RQSheet

struct IPadTileLayoutTests {
    @Test func portraitPreservesReadingSequenceAcrossTwoColumns() {
        let layout = IPadTileArrangement(width: 1024, height: 1366)

        #expect(layout.order == [.summary, .runes, .combat, .magic, .skills1, .skills2, .equipment, .notes])
        #expect(layout.columnCount == 2)
        #expect(!layout.usesPhoneLayout)
    }

    @Test func landscapePreservesReadingSequenceAcrossThreeColumns() {
        let layout = IPadTileArrangement(width: 1366, height: 1024)

        #expect(layout.order == [.summary, .runes, .magic, .combat, .skills1, .skills2, .equipment, .notes])
        #expect(layout.columnCount == 3)
        #expect(Set(layout.order) == Set(IPadCharacterTile.allCases))
    }

    @Test(arguments: [320.0, 500.0, 679.0])
    func narrowWindowUsesPhoneShell(width: Double) {
        let layout = IPadTileArrangement(width: width, height: 900)
        #expect(layout.usesPhoneLayout)
    }

    @Test func thresholdUsesTilesAndSquareWindowUsesPortraitOrder() {
        #expect(!IPadTileArrangement(width: 680, height: 900).usesPhoneLayout)
        #expect(IPadTileArrangement(width: 900, height: 900).columnCount == 2)
        #expect(IPadTileArrangement(width: 900, height: 900).order == [.summary, .runes, .combat, .magic, .skills1, .skills2, .equipment, .notes])
    }

    @Test func columnPartitionUsesContiguousRangesAndBalancesEqualTiles() {
        let ranges = IPadColumnPartition.partition(heights: [100, 100, 100, 100, 100, 100, 100, 100], columnCount: 2)

        #expect(ranges == [0..<4, 4..<8])
    }

    @Test func columnPartitionChoosesMinimumHeightRangeAndEarliestTie() {
        let ranges = IPadColumnPartition.partition(heights: [10, 50, 10, 50, 10], columnCount: 2)

        #expect(ranges == [0..<2, 2..<5])
    }

    @Test func columnPartitionReturnsAllTilesOnceForThreeColumns() {
        let ranges = IPadColumnPartition.partition(heights: [10, 20, 30, 40, 50, 60, 70, 80], columnCount: 3)

        #expect(ranges.flatMap(Array.init) == Array(0..<8))
        #expect(ranges.count == 3)
    }

    @Test func skillAreasSplitDynamicallyForUnevenCounts() {
        let split = IPadSkillGroupPartition.split(skillCounts: [
            .agility: 9,
            .communication: 19,
            .knowledge: 39,
            .manipulation: 6,
            .magic: 4,
            .perception: 6,
            .stealth: 3
        ])

        #expect(split.first == [.agility, .communication])
        #expect(split.second == [.knowledge, .manipulation, .magic, .perception, .stealth])
    }

    @Test func emptySkillAreasSplitWithoutOmittingOrDuplicatingGroups() {
        let split = IPadSkillGroupPartition.split(skillCounts: [:])

        #expect(split.first == Array(SkillGroup.allCases.prefix(3)))
        #expect(split.second == Array(SkillGroup.allCases.suffix(4)))
        #expect(split.first + split.second == SkillGroup.allCases)
    }

    @Test func equalSkillCountsUseEarliestBalancedBoundary() {
        let split = IPadSkillGroupPartition.split(skillCounts: Dictionary(uniqueKeysWithValues: SkillGroup.allCases.map { ($0, 1) }))

        #expect(split.first == Array(SkillGroup.allCases.prefix(3)))
        #expect(split.second == Array(SkillGroup.allCases.suffix(4)))
    }
}
