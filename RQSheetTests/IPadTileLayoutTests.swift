import Foundation
import Testing
@testable import RQSheet

struct IPadTileLayoutTests {
    @Test func portraitUsesRequestedRows() {
        let layout = IPadTileArrangement(width: 1024, height: 1366)
        #expect(layout.rows == [[.summary, .runes], [.combat, .magic], [.skills, .knowledge], [.equipment, .notes]])
        #expect(layout.columnCount == 2)
        #expect(!layout.usesPhoneLayout)
    }
    @Test func landscapeUsesRequestedRows() {
        let layout = IPadTileArrangement(width: 1366, height: 1024)
        #expect(layout.rows == [[.summary, .runes, .magic], [.combat, .skills, .knowledge], [.equipment, .notes]])
        #expect(layout.columnCount == 3)
        #expect(layout.rows.flatMap { $0 }.count == 8)
        #expect(Set(layout.rows.flatMap { $0 }) == Set(IPadCharacterTile.allCases))
    }
    @Test(arguments: [320.0, 500.0, 679.0]) func narrowIPadUsesPhoneShell(width: Double) {
        let layout = IPadTileArrangement(width: width, height: 900)
        #expect(layout.usesPhoneLayout)
    }
    @Test func thresholdUsesTilesAndSquareWindowUsesPortrait() {
        #expect(!IPadTileArrangement(width: 680, height: 900).usesPhoneLayout)
        #expect(IPadTileArrangement(width: 900, height: 900).columnCount == 2)
    }
    @Test func skillSplitKeepsEveryGroupExactlyOnce() {
        let groups = IPadCharacterTile.skills.skillGroups + IPadCharacterTile.knowledge.skillGroups
        #expect(groups.count == SkillGroup.allCases.count)
        #expect(Set(groups) == Set(SkillGroup.allCases))
        #expect(IPadCharacterTile.knowledge.skillGroups == [.knowledge])
        #expect(!IPadCharacterTile.skills.skillGroups.contains(.knowledge))
    }
}
