import CoreGraphics
import Testing
@testable import RQSheet

struct SwipeDirectionLockTests {
    @Test
    func horizontalTranslationActivatesSwipe() {
        #expect(SwipeDirectionLock.isHorizontalSwipe(CGPoint(x: -40, y: 12)))
    }

    @Test
    func verticalTranslationDoesNotActivateSwipe() {
        #expect(SwipeDirectionLock.isHorizontalSwipe(CGPoint(x: -14, y: 22)) == false)
    }

    @Test
    func swipeRevealMetricsIncludeConfiguredGapAndPillCap() {
        let metrics = SwipeRevealMetrics(deleteWidth: 92, trailingPadding: 8, revealGap: 15, pillOvershootLimit: 10)

        #expect(metrics.revealedRowOffset == -115)
        #expect(metrics.rowOffset(forProposedOffset: -260) == -260)
        #expect(metrics.pillOffset(forRowOffset: -80) == 0)
        #expect(metrics.pillOffset(forRowOffset: -115) == 0)
        #expect(metrics.pillOffset(forRowOffset: -121) == -6)
        #expect(metrics.pillOffset(forRowOffset: -140) == -10)
    }
}
