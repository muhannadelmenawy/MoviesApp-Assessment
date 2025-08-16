//
//  MoviesAppUITestsLaunchTests.swift
//  MoviesAppUITests
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import XCTest

final class MoviesAppUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        // Stop immediately when a failure occurs
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let header = app.staticTexts["Watch New Movies"]
        XCTAssertTrue(header.waitForExistence(timeout: 8), "App did not show the main screen after launch")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
