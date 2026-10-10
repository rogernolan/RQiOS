import Foundation
import Testing
@testable import RQSheet

struct WorkspaceLayoutTests {
    @Test
    func ipadContentFitsBothWideAndNarrowWindows() {
        #expect(WorkspaceLayout.contentWidth(availableWidth: 1366, isPad: true) == 900)
        #expect(WorkspaceLayout.contentWidth(availableWidth: 375, isPad: true) == 375)
        #expect(WorkspaceLayout.contentWidth(availableWidth: 430, isPad: false) == 430)
    }

    @Test(arguments: [320.0, 375.0, 768.0, 900.0])
    func ipadPortraitStaysCompactAndFitsContent(width: Double) {
        let layout = IPadSummaryProfileLayout(availableWidth: width)
        #expect(layout.portraitSize <= 144)
        #expect(layout.portraitSize >= 80)
        #expect(layout.portraitSize + 28 <= width)
        #expect(layout.usesHorizontalLayout == (width >= 420))
    }
}
