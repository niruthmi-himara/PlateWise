import XCTest

/// UI tests: tap through the app like a real user would.
final class PlateWiseUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-hasSeenOnboarding", "YES"]   // Skip onboarding in most tests
        app.launch()
    }

    /// A first-time user can go through the onboarding and reach the Today screen.
    @MainActor
    func testOnboardingFlow() {
        app.terminate()
        app.launchArguments = ["-hasSeenOnboarding", "NO"]
        app.launch()

        let next = app.buttons["Continue"]
        XCTAssertTrue(next.waitForExistence(timeout: 3))
        next.tap()
        next.tap()
        next.tap()

        let start = app.buttons["Get Started"]
        XCTAssertTrue(start.waitForExistence(timeout: 3))
        start.tap()
        XCTAssertTrue(app.buttons["Add Meal"].waitForExistence(timeout: 3))
    }

    /// All three tabs open and show the right screen.
    @MainActor
    func testAllThreeTabsOpen() {
        app.tabBars.buttons["History"].tap()
        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 3))

        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))

        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(app.buttons["Add Meal"].waitForExistence(timeout: 3))
    }

    /// A user can add a Sri Lankan dish from the menu and see it on Today.
    @MainActor
    func testAddSriLankanDishFromMenu() {
        app.buttons["Add Meal"].tap()

        let menu = app.buttons["Choose a Sri Lankan dish"]
        XCTAssertTrue(menu.waitForExistence(timeout: 3))
        menu.tap()
        app.buttons["Kottu roti · 750 kcal"].tap()

        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts["Kottu roti"].firstMatch.waitForExistence(timeout: 3))
    }

    /// Save stays disabled until the form is filled in.
    @MainActor
    func testSaveDisabledForEmptyMeal() {
        app.buttons["Add Meal"].tap()
        let save = app.buttons["Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 3))
        XCTAssertFalse(save.isEnabled)
        app.buttons["Cancel"].tap()
    }

    /// Demo data loads and the theme can be switched to Dark and back.
    @MainActor
    func testDemoDataAndDarkMode() {
        app.tabBars.buttons["Settings"].tap()
        app.buttons["Load demo data"].tap()
        let ok = app.alerts.buttons["OK"]
        XCTAssertTrue(ok.waitForExistence(timeout: 3))
        ok.tap()

        app.buttons["Dark"].tap()
        app.buttons["System"].tap()

        app.tabBars.buttons["History"].tap()
        XCTAssertFalse(app.staticTexts["No history yet"].exists)
    }

    /// Measures how long the app takes to launch (performance).
    @MainActor
    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
