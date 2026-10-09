import UIKit
import XCTest

final class WorkspaceNavigationUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testIPadShowsTilesInBothOrientations() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad)
        let app = openNewCharacter()
        XCTAssertTrue(app.scrollViews["workspace.tiles"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.tabBars.firstMatch.isHittable)
        XCTAssertFalse(app.buttons["workspace.sectionMenu"].exists)
        let portrait = [["summary", "runes"], ["combat", "magic"], ["skills", "knowledge"], ["equipment", "notes"]]
        let landscape = [["summary", "runes", "magic"], ["combat", "skills", "knowledge"], ["equipment", "notes"]]
        for (orientation, rows) in [(UIDeviceOrientation.portrait, portrait), (.landscapeLeft, landscape)] {
            XCUIDevice.shared.orientation = orientation
            for row in rows {
                let headings = row.map { app.staticTexts["tile.\($0).title"] }
                for heading in headings {
                    XCTAssertTrue(heading.waitForExistence(timeout: 3))
                    XCTAssertGreaterThanOrEqual(heading.frame.minX, 0)
                    XCTAssertLessThanOrEqual(heading.frame.maxX, app.frame.maxX)
                }
                for index in 1..<headings.count {
                    XCTAssertEqual(headings[index].frame.minY, headings[0].frame.minY, accuracy: 2)
                    XCTAssertGreaterThan(headings[index].frame.minX, headings[index - 1].frame.minX)
                }
            }
            let summaryTile = app.descendants(matching: .any)
                .matching(identifier: "tile.summary")
                .firstMatch
            XCTAssertTrue(summaryTile.exists)
            XCTAssertFalse(summaryTile.staticTexts["Top Rune Affinities"].exists)
            XCTAssertFalse(summaryTile.staticTexts["Skill Bonuses"].exists)
            attachScreenshot(app, name: "iPad tiles \(orientation == .portrait ? "portrait" : "landscape")")
        }
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    func testSelectingCharacterFromListOpensDetails() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing-in-memory", "-ui-testing-seed-tiles"]
        app.launch()

        let character = app.buttons.containing(.staticText, identifier: "Tile Test Character").firstMatch
        XCTAssertTrue(character.waitForExistence(timeout: 10))
        character.tap()

        XCTAssertTrue(app.scrollViews["workspace.tiles"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testIPadSettingsRetainsImportDraftAndCharacterEditing() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad)
        let app = openNewCharacter()
        app.buttons["Edit character details"].tap()
        XCTAssertTrue(app.navigationBars["Character Editor"].waitForExistence(timeout: 3))
        app.navigationBars.buttons.firstMatch.tap()
        let settings = app.buttons["workspace.settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 3))
        settings.tap()
        let editor = app.textViews.firstMatch
        XCTAssertTrue(editor.waitForExistence(timeout: 3))
        editor.tap()
        editor.typeText("Unfinished character import")
        app.buttons["workspace.closeSettings"].tap()
        XCTAssertTrue(app.scrollViews["workspace.tiles"].exists)
        settings.tap()
        XCTAssertEqual(editor.value as? String, "Unfinished character import")
    }

    @MainActor
    func testIPadKeepsSearchStateAcrossRotationAndCompactLayout() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad)
        let app = openPopulatedCharacter(resizeTesting: true)
        let search = app.textFields["knowledge.search"]
        scrollTo(search, in: app)
        search.tap()
        search.typeText("skill 39")
        XCTAssertTrue(app.staticTexts["Knowledge skill 39"].exists)
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertEqual(search.value as? String, "skill 39")
        app.buttons["workspace.testResize"].tap()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 3))
        XCTAssertFalse(app.scrollViews["workspace.tiles"].isHittable)
        XCTAssertFalse(app.staticTexts["tile.summary.title"].exists)
        app.tabBars.buttons["Skills"].tap()
        XCTAssertTrue(app.textFields["Search skills"].waitForExistence(timeout: 3))
        app.buttons["workspace.testResize"].tap()
        XCTAssertTrue(app.scrollViews["workspace.tiles"].waitForExistence(timeout: 3))
        XCTAssertEqual(search.value as? String, "skill 39")
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    func testIPadLongListsAndGrowingNotesUseThePageScroll() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad)
        let app = openPopulatedCharacter()
        let notes = app.textViews["notes.editor"]
        scrollTo(notes, in: app)
        let before = notes.frame.height
        notes.tap()
        notes.typeText(String(repeating: "\nA new line of character notes.", count: 12))
        XCTAssertGreaterThan(notes.frame.height, before)
        attachScreenshot(app, name: "Notes after typing")
        XCTAssertTrue(notes.debugDescription.contains("Keyboard Focused"))
        XCTAssertLessThan(notes.frame.minY, app.keyboards.firstMatch.frame.minY)
        XCTAssertTrue(app.keyboards.firstMatch.exists)
        app.buttons["workspace.settings"].tap()
        app.buttons["workspace.closeSettings"].tap()
        XCTAssertFalse(app.keyboards.firstMatch.exists)
        let finalKnowledge = app.staticTexts["Knowledge skill 39"]
        scrollTo(finalKnowledge, in: app, upwards: false)
        XCTAssertTrue(finalKnowledge.isHittable)
        let heading = app.staticTexts["tile.summary.title"]
        let beforeY = heading.frame.minY
        let row = finalKnowledge.frame
        let start = app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: row.midX, dy: min(row.midY, app.frame.maxY - 120)))
        let end = start.withOffset(CGVector(dx: 0, dy: 300))
        start.press(forDuration: 0.05, thenDragTo: end)
        XCTAssertGreaterThan(heading.frame.minY, beforeY)
        attachScreenshot(app, name: "iPad populated full page")
    }

    @MainActor
    func testIPadNarrowLandscapeKeepsThreeColumnsAndControlsWithinTiles() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad)
        let app = openPopulatedCharacter(resizeTesting: true)
        app.buttons["workspace.testNarrowLandscape"].tap()
        let runes = app.otherElements["tile.runes"]
        let summaryTitle = app.staticTexts["tile.summary.title"]
        let runeTitle = app.staticTexts["tile.runes.title"]
        let magicTitle = app.staticTexts["tile.magic.title"]
        XCTAssertEqual(summaryTitle.frame.minY, runeTitle.frame.minY, accuracy: 2)
        XCTAssertEqual(runeTitle.frame.minY, magicTitle.frame.minY, accuracy: 2)
        XCTAssertGreaterThan(magicTitle.frame.minX, runeTitle.frame.minX)
        for name in ["Fire", "Darkness", "Earth", "Water", "Air", "Moon", "Truth", "Illusion"] {
            let label = runes.staticTexts[name].firstMatch
            XCTAssertTrue(label.exists)
            XCTAssertGreaterThanOrEqual(label.frame.minX, runes.frame.minX)
            XCTAssertLessThanOrEqual(label.frame.maxX, runes.frame.maxX)
        }
        attachScreenshot(app, name: "iPad narrow landscape")
    }

    @MainActor
    func testIPadSkillEditingChecksAndDeleteRemainAvailable() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad)
        let app = openPopulatedCharacter()
        let search = app.textFields["knowledge.search"]
        scrollTo(search, in: app)
        search.tap()
        search.typeText("skill 39")
        app.buttons["workspace.settings"].tap()
        app.buttons["workspace.closeSettings"].tap()
        let check = app.buttons["skills.check.Knowledge skill 39"]
        scrollTo(check, in: app)
        XCTAssertEqual(check.value as? String, "Unchecked")
        check.tap()
        XCTAssertEqual(check.value as? String, "Checked")
        app.staticTexts["Knowledge skill 39"].tap()
        XCTAssertTrue(app.navigationBars["Edit Skill"].waitForExistence(timeout: 3))
        let percentage = app.textFields["%"]
        percentage.doubleTap()
        percentage.typeText("82")
        attachScreenshot(app, name: "Skill before saving")
        app.navigationBars["Edit Skill"].buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts["82%"].waitForExistence(timeout: 3))
        let actions = app.buttons["Actions for Knowledge skill 39"]
        scrollTo(actions, in: app)
        actions.tap()
        app.buttons["Delete"].tap()
        app.alerts.buttons["Yes"].tap()
        XCTAssertFalse(app.staticTexts["Knowledge skill 39"].exists)
    }

    @MainActor
    private func scrollTo(_ element: XCUIElement, in app: XCUIApplication, upwards: Bool = true) {
        let page = app.scrollViews["workspace.tiles"]
        let visibleTop = app.navigationBars.firstMatch.frame.maxY
        let visibleBottom = app.frame.maxY - 80
        for _ in 0..<22 {
            let frame = element.frame
            if frame.minY >= visibleTop && frame.maxY <= visibleBottom { return }
            if frame.minY < visibleTop {
                page.swipeDown()
            } else {
                page.swipeUp()
            }
        }
        let finalFrame = element.frame
        XCTAssertGreaterThanOrEqual(finalFrame.minY, visibleTop)
        XCTAssertLessThanOrEqual(finalFrame.maxY, visibleBottom)
    }

    @MainActor
    private func openPopulatedCharacter(resizeTesting: Bool = false) -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing-in-memory", "-ui-testing-seed-tiles"]
        if resizeTesting { app.launchArguments.append("-ui-testing-enable-resize") }
        app.launch()
        let character = app.buttons.containing(.staticText, identifier: "Tile Test Character").firstMatch
        XCTAssertTrue(character.waitForExistence(timeout: 10))
        character.tap()
        XCTAssertTrue(app.scrollViews["workspace.tiles"].waitForExistence(timeout: 5))
        return app
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
