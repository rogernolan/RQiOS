import Testing
import UIKit
@testable import RQSheet

struct KeyboardOverlapObserverTests {
    @Test func dockedKeyboardInsetsOnlyTheVisibleOverlap() {
        let viewport = CGRect(x: 0, y: 86, width: 1024, height: 1290)
        let keyboard = CGRect(x: 0, y: 1028, width: 1024, height: 348)
        #expect(KeyboardOverlapObserver.bottomInset(viewport: viewport, keyboard: keyboard) == 348)
    }

    @Test func keyboardOutsideShortWindowDoesNotShrinkItsContent() {
        let viewport = CGRect(x: 150, y: 120, width: 700, height: 400)
        let keyboard = CGRect(x: 0, y: 1028, width: 1024, height: 348)
        #expect(KeyboardOverlapObserver.bottomInset(viewport: viewport, keyboard: keyboard) == 0)
    }

    @Test func floatingOrNarrowKeyboardDoesNotBecomeAFullWidthBottomInset() {
        let viewport = CGRect(x: 0, y: 0, width: 1024, height: 1366)
        let floating = CGRect(x: 300, y: 700, width: 424, height: 300)
        let narrowDocked = CGRect(x: 220, y: 1028, width: 600, height: 338)
        #expect(KeyboardOverlapObserver.bottomInset(viewport: viewport, keyboard: floating) == 0)
        #expect(KeyboardOverlapObserver.bottomInset(viewport: viewport, keyboard: narrowDocked) == 0)
    }
}
