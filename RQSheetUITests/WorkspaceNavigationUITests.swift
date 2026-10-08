import UIKit
import XCTest

final class WorkspaceNavigationUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testIPadUsesPopoverToReachEverySection() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad)
        let app = openNewCharacter()
        let sectionMenu = app.buttons["workspace.sectionMenu"]
        XCTAssertTrue(sectionMenu.waitForExistence(timeout: 5))
        XCTAssertFalse(app.tabBars.firstMatch.exists)

        for section in ["combat", "skills", "runes", "magic", "equipment", "notes", "settings", "summary"] {
            sectionMenu.tap()
            let destination = app.buttons["workspace.section.\(section)"]
            XCTAssertTrue(destination.waitForExistence(timeout: 3))
            if section == "combat" {
                attachScreenshot(app, name: "iPad section popover")
            }
            destination.tap()
            XCTAssertFalse(destination.waitForExistence(timeout: 1))
            XCTAssertTrue(sectionMenu.exists)
            let title = section == "summary" ? "New character" : section == "runes" ? "Rune affinities" : section.capitalized
            XCTAssertTrue(app.navigationBars.staticTexts[title].exists)
        }

        XCTAssertTrue(app.buttons["Edit character details"].exists)
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Characters"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testIPadSummaryKeepsCompactPortraitInBothOrientations() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad)
        let app = openNewCharacter()
        for orientation in [UIDeviceOrientation.portrait, .landscapeLeft] {
            XCUIDevice.shared.orientation = orientation
            let profile = app.otherElements["summary.ipadProfile"]
            XCTAssertTrue(profile.waitForExistence(timeout: 5))
            XCTAssertLessThanOrEqual(profile.frame.width, 900)
            XCTAssertLessThan(profile.frame.height, 250)
            let strengthLabel = app.staticTexts["summary.characteristic.STR.label"]
            XCTAssertTrue(strengthLabel.exists)
            XCTAssertGreaterThan(strengthLabel.frame.minY, profile.frame.maxY)
            XCTAssertLessThan(strengthLabel.frame.maxY, app.frame.maxY)
            attachScreenshot(app, name: "iPad Summary \(orientation == .portrait ? "portrait" : "landscape")")
        }
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    func testIPadPopoverDismissalAndSummaryEditing() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad)
        let app = openNewCharacter()
        let sectionMenu = app.buttons["workspace.sectionMenu"]
        XCTAssertTrue(sectionMenu.waitForExistence(timeout: 5))
        sectionMenu.tap()
        let combat = app.buttons["workspace.section.combat"]
        XCTAssertTrue(combat.waitForExistence(timeout: 3))
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5)).tap()
        XCTAssertFalse(combat.exists)
        XCTAssertTrue(app.navigationBars.staticTexts["New character"].exists)
        app.buttons["Edit character details"].tap()
        XCTAssertTrue(app.navigationBars["Character Editor"].waitForExistence(timeout: 3))
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(sectionMenu.waitForExistence(timeout: 3))
        XCTAssertTrue(app.navigationBars.staticTexts["New character"].exists)
    }

    @MainActor
    func testIPadPreservesImportDraftWhenSwitchingSections() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad)
        let app = openNewCharacter()
        let menu = app.buttons["workspace.sectionMenu"]
        XCTAssertTrue(menu.waitForExistence(timeout: 5))
        menu.tap()
        app.buttons["workspace.section.settings"].tap()
        let editor = app.textViews.firstMatch
        XCTAssertTrue(editor.waitForExistence(timeout: 3))
        editor.tap()
        editor.typeText("Unfinished character import")
        menu.tap()
        app.buttons["workspace.section.summary"].tap()
        menu.tap()
        app.buttons["workspace.section.settings"].tap()
        XCTAssertEqual(editor.value as? String, "Unfinished character import")
    }

    @MainActor
    func testPhoneRetainsTabsAndEveryMoreDestination() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .phone)
        let app = openNewCharacter()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["workspace.sectionMenu"].exists)
        for title in ["Combat", "Skills", "Runes", "Summary"] {
            let tab = app.tabBars.buttons[title]
            XCTAssertTrue(tab.exists)
            tab.tap()
        }
        for title in ["Magic", "Equipment", "Notes", "Settings"] {
            app.tabBars.buttons["More"].tap()
            let destination = app.buttons[title].firstMatch
            XCTAssertTrue(destination.waitForExistence(timeout: 3))
            destination.tap()
            XCTAssertTrue(app.staticTexts[title].firstMatch.waitForExistence(timeout: 3))
        }
        attachScreenshot(app, name: "iPhone tab bar")
    }

    @MainActor
    private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func openNewCharacter() -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchArguments += ["-ui-testing-in-memory"]
        app.launch()
        let create = app.buttons["Create New Character"]
        XCTAssertTrue(create.waitForExistence(timeout: 10))
        create.tap()
        return app
    }
}
