import XCTest

/// Drives the deep-link paths end to end and attaches a screenshot at each step.
/// Export them with `xcrun xcresulttool export attachments`.
final class DeepLinkFlowTests: XCTestCase {
    private let link = "coordinators://post/103/comments"

    override func setUp() {
        continueAfterFailure = false
    }

    func testColdStartLinkWaitsThroughOnboardingAndSignIn() {
        let app = XCUIApplication()
        app.launchArguments = ["-deeplink", link, "-onboarding", "YES"]
        app.launch()

        XCTAssertTrue(app.buttons["Skip"].waitForExistence(timeout: 5))
        snap(app, "cold-1-onboarding")
        app.buttons["Skip"].tap()

        XCTAssertTrue(app.buttons["Sign in"].waitForExistence(timeout: 5))
        snap(app, "cold-2-welcome")
        app.buttons["Sign in"].tap()

        XCTAssertTrue(app.staticTexts["Grace Hopper"].waitForExistence(timeout: 5))
        snap(app, "cold-3-signin")
        app.staticTexts["Grace Hopper"].tap()

        XCTAssertTrue(app.navigationBars["Comments"].waitForExistence(timeout: 8))
        sleep(1)
        snap(app, "cold-4-comments")
    }

    func testWarmLinkDismissesTheSheetFirst() {
        let app = XCUIApplication()
        app.launchArguments = ["-autoLogin", "YES"]
        app.launch()

        XCTAssertTrue(app.buttons["feed.compose"].waitForExistence(timeout: 5))
        app.buttons["feed.compose"].tap()
        XCTAssertTrue(app.navigationBars["New post"].waitForExistence(timeout: 5))
        sleep(1)
        snap(app, "warm-1-sheet")

        XCUIDevice.shared.system.open(URL(string: link)!)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let open = springboard.buttons["Open"]
        if open.waitForExistence(timeout: 3) { open.tap() }

        XCTAssertTrue(app.navigationBars["Comments"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.navigationBars["New post"].exists)
        sleep(1)
        snap(app, "warm-2-comments")
    }

    private func snap(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
