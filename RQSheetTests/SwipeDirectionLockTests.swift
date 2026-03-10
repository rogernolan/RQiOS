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
}
