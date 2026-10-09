//
//  RQSheetUITests.swift
//  RQSheetUITests
//
//  Created by Roger Nolan on 21/02/2026.
//

import XCTest

final class RQSheetUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testSummaryCharacteristicsRemainVisibleAfterScrollCycle() throws {
        let app = XCUIApplication()
        launchApp(app)

        if app.buttons["Create New Character"].waitForExistence(timeout: 3) {
            app.buttons["Create New Character"].tap()
        }

        if app.tabBars.buttons["Summary"].exists {
            app.tabBars.buttons["Summary"].tap()
        }

        let strChip = app.otherElements["summary.characteristic.STR"]
        let conChip = app.otherElements["summary.characteristic.CON"]
        let sizChip = app.otherElements["summary.characteristic.SIZ"]

        XCTAssertTrue(strChip.waitForExistence(timeout: 12))
        XCTAssertTrue(conChip.exists)
        XCTAssertTrue(sizChip.exists)

        let summaryScrollView = app.scrollViews.firstMatch
        XCTAssertTrue(summaryScrollView.exists)

        for _ in 0..<4 {
            summaryScrollView.swipeUp()
        }
        for _ in 0..<4 {
            summaryScrollView.swipeDown()
        }

        XCTAssertTrue(strChip.waitForExistence(timeout: 5))
        XCTAssertTrue(conChip.exists)
        XCTAssertTrue(sizChip.exists)
    }

    @MainActor
    func testEquipmentAddButtonIsVisibleAndTappable() throws {
        let app = XCUIApplication()
        openEquipmentTab(in: app)

        let addButton = app.buttons["equipment.addItem"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 12))
        XCTAssertTrue(addButton.isHittable)
        XCTAssertLessThan(addButton.frame.maxY, app.tabBars.firstMatch.frame.minY)
    }

    @MainActor
    func testEquipmentAddButtonPresentsSheet() throws {
        let app = XCUIApplication()
        openEquipmentTab(in: app)

        app.buttons["equipment.addItem"].tap()

        XCTAssertTrue(app.navigationBars["Add Equipment"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testEquipmentRowPresentsEditSheet() throws {
        let app = XCUIApplication()
        openEquipmentTab(in: app)

        app.buttons["equipment.addItem"].tap()
        XCTAssertTrue(app.navigationBars["Add Equipment"].waitForExistence(timeout: 5))

        let nameField = app.textFields["Name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("Shield")

        app.navigationBars.buttons["Save"].tap()

        let rowName = app.staticTexts["Shield"]
        XCTAssertTrue(rowName.waitForExistence(timeout: 5))
        rowName.tap()

        XCTAssertTrue(app.navigationBars["Edit Equipment"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["Name"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.textFields["Name"].value as? String, "Shield")
    }

    @MainActor
    func testMagicAddButtonPresentsSheet() throws {
        let app = XCUIApplication()
        openMagicTab(in: app)

        let addButton = app.buttons["Add new spell"].firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        XCTAssertTrue(app.navigationBars["Add Spirit Magic"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testMagicRowPresentsEditSheet() throws {
        let app = XCUIApplication()
        openMagicTab(in: app)

        let addButton = app.buttons["Add new spell"].firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let nameField = app.textFields["Name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("Bladesharp")

        app.navigationBars.buttons["Save"].tap()

        let rowButton = app.buttons["Bladesharp"]
        XCTAssertTrue(rowButton.waitForExistence(timeout: 5))
        rowButton.tap()

        XCTAssertTrue(app.navigationBars["Edit Spirit Magic"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.textFields["Name"].value as? String, "Bladesharp")
    }

    @MainActor
    func testCombatWeaponsScrollVerticallyWhenDraggingOnRow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-ui-testing-seed-combat-weapons"]
        app.launch()
        let testCharacter = app.buttons["UI Test Character"]
        XCTAssertTrue(testCharacter.waitForExistence(timeout: 12), "The simulator UI test app must seed its combat fixture.")
        testCharacter.tap()
        XCTAssertTrue(app.tabBars.buttons["Combat"].waitForExistence(timeout: 12))
        app.tabBars.buttons["Combat"].tap()

        let weaponsList = app.scrollViews["combat.weaponsList"]
        XCTAssertTrue(weaponsList.waitForExistence(timeout: 12))

        let topRow = app.otherElements["combat.weaponRow.Weapon 1"]
        let lowerRow = app.otherElements["combat.weaponRow.Weapon 12"]
        let addButton = app.buttons["combat.addWeapon"]

        XCTAssertTrue(topRow.waitForExistence(timeout: 5))
        XCTAssertTrue(addButton.exists)
        XCTAssertFalse(lowerRow.isHittable)

        topRow.swipeUp()

        XCTAssertTrue(lowerRow.waitForExistence(timeout: 5))
        XCTAssertTrue(lowerRow.isHittable)
        XCTAssertFalse(addButton.isHittable)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures isolated UI-test startup. The -ui-testing argument selects
        // an in-memory store and disables CloudKit diagnostics for simulator stability.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            launchApp(XCUIApplication())
        }
    }

    @MainActor
    private func openEquipmentTab(in app: XCUIApplication) {
        launchApp(app)

        if app.buttons["Create New Character"].waitForExistence(timeout: 3) {
            app.buttons["Create New Character"].tap()
        }

        if app.tabBars.buttons["Equipment"].waitForExistence(timeout: 5) {
            app.tabBars.buttons["Equipment"].tap()
            return
        }

        XCTAssertTrue(app.tabBars.buttons["More"].waitForExistence(timeout: 12))
        app.tabBars.buttons["More"].tap()

        let equipmentButton = app.buttons["Equipment"]
        XCTAssertTrue(equipmentButton.waitForExistence(timeout: 5))
        equipmentButton.tap()
    }

    @MainActor
    private func openMagicTab(in app: XCUIApplication) {
        launchApp(app)

        if app.buttons["Create New Character"].waitForExistence(timeout: 3) {
            app.buttons["Create New Character"].tap()
        }

        if app.tabBars.buttons["Magic"].waitForExistence(timeout: 5) {
            app.tabBars.buttons["Magic"].tap()
            return
        }

        XCTAssertTrue(app.tabBars.buttons["More"].waitForExistence(timeout: 12))
        app.tabBars.buttons["More"].tap()

        let magicButton = app.buttons["Magic"]
        XCTAssertTrue(magicButton.waitForExistence(timeout: 5))
        magicButton.tap()
    }

    private func launchApp(_ app: XCUIApplication) {
        app.launchArguments.append("-ui-testing")
        app.launch()
    }
}
