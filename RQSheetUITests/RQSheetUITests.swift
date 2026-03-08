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
        app.launch()

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

        let rowButton = app.buttons["Shield"]
        XCTAssertTrue(rowButton.waitForExistence(timeout: 5))
        rowButton.tap()

        XCTAssertTrue(app.navigationBars["Edit Equipment"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["Name"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.textFields["Name"].value as? String, "Shield")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    private func openEquipmentTab(in app: XCUIApplication) {
        app.launch()

        if app.buttons["Create New Character"].waitForExistence(timeout: 3) {
            app.buttons["Create New Character"].tap()
        }

        XCTAssertTrue(app.tabBars.buttons["Equipment"].waitForExistence(timeout: 12))
        app.tabBars.buttons["Equipment"].tap()
    }
}
