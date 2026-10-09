import SwiftUI
import Testing
@testable import RQSheet

@MainActor
struct RuneTileGeometryTests {
    @Test func compactNodesFitWithoutOverlapAtNarrowTileWidths() {
        let metrics = RuneTileGeometry(width: 180, isCompact: true)
        for index in 0..<16 {
            let point = metrics.position(of: index)
            let width: CGFloat = index < 6 ? 112 : 124
            #expect(point.x - width / 2 >= 0)
            #expect(point.x + width / 2 <= metrics.width)
            #expect(point.y - 29 >= 0)
            #expect(point.y + 29 <= metrics.height)
            if index > 0 {
                #expect(point.y - metrics.position(of: index - 1).y >= 58)
            }
        }
    }

    @Test func normalWidthDiagramKeepsEveryEditorInsideItsBounds() {
        let metrics = RuneTileGeometry(width: 340, isCompact: false)
        for index in 0..<16 {
            let point = metrics.position(of: index)
            let width: CGFloat = index < 6 ? 112 : 124
            #expect(point.x - width / 2 >= 0)
            #expect(point.x + width / 2 <= metrics.width)
            #expect(point.y - 29 >= 0)
            #expect(point.y + 29 <= metrics.height)
        }
    }
}
