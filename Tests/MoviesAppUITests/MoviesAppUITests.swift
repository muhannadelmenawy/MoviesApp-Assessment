//
//  MoviesAppUITests.swift
//  MoviesAppUITests
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import XCTest

final class MoviesAppUITests: XCTestCase {

    // MARK: - Helpers
    private func waitForHeader(_ app: XCUIApplication, timeout: TimeInterval = 10) {
        let header = app.staticTexts["Watch New Movies"]
        XCTAssertTrue(header.waitForExistence(timeout: timeout), "Header 'Watch New Movies' did not appear")
    }

    /// Count visible labels that look like a 4-digit year (used as a proxy for number of grid items).
    private func visibleYearLabelsCount(in app: XCUIApplication) -> Int {
        let regex = try! NSRegularExpression(pattern: #"^\d{4}$"#)
        return app.staticTexts.allElementsBoundByIndex.filter { el in
            let s = el.label
            guard !s.isEmpty else { return false }
            return regex.numberOfMatches(in: s, range: NSRange(location: 0, length: s.count)) > 0
        }.count
    }

    /// Tap the first genre chip that is NOT "All".
    private func tapFirstGenreChip(app: XCUIApplication) {
        let buttons = app.buttons.allElementsBoundByIndex
        guard let chip = buttons.first(where: { $0.label != "All" && !$0.label.isEmpty }) else {
            XCTFail("No genre chip found")
            return
        }
        chip.tap()
    }

    // MARK: - Tests
    private func waitForDetailsScreen(in app: XCUIApplication,
                                      timeout: TimeInterval = 10) -> Bool {
        // strong signals that we're on the details screen
        let keywordLabels = ["Overview", "Status", "Runtime", "Budget", "Revenue", "Homepage"]
            .map { app.staticTexts[$0] }

        // also accept any text that looks like "(YYYY)" which our title shows
        let yearRegex = try! NSRegularExpression(pattern: #"\(\d{4}\)"#)

        let start = Date()
        while Date().timeIntervalSince(start) < timeout {
            // any of the keyword labels?
            if keywordLabels.contains(where: { $0.exists }) { return true }

            // any static text matching "(YYYY)"?
            let hasYearTitle = app.staticTexts.allElementsBoundByIndex.contains { el in
                let s = el.label
                guard !s.isEmpty else { return false }
                return yearRegex.numberOfMatches(in: s, range: NSRange(location: 0, length: s.count)) > 0
            }
            if hasYearTitle { return true }

            RunLoop.current.run(until: Date().addingTimeInterval(0.5))
        }
        return false
    }

    func testPaginationLoadsMoreOnSwipe() {
        let app = XCUIApplication()
        app.launch()

        waitForHeader(app)

        let initial = visibleYearLabelsCount(in: app)
        let scroll = app.scrollViews.firstMatch
        XCTAssertTrue(scroll.waitForExistence(timeout: 8), "Movies grid did not appear")

        // Swipe to trigger next pages
        for _ in 0..<4 {
            scroll.swipeUp()
            RunLoop.current.run(until: Date().addingTimeInterval(0.7))
        }

        let after = visibleYearLabelsCount(in: app)
        XCTAssertTrue(after >= initial, "Expected more items after pagination swipe (initial: \(initial), after: \(after))")
    }
}
