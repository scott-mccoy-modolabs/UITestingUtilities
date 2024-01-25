/*
 * Copyright © 2010 - 2024 Modo Labs Inc. All rights reserved.
 *
 * The license governing the contents of this file is located in the LICENSE
 * file located at the root directory of this distribution. If the LICENSE file
 * is missing, please contact sales@modolabs.com.
 *
 */

import Foundation
import XCTest

// MARK: Entering Text
extension XCUIElement {

    public func clearAndEnterText(
        _ newValue: String,
        app: XCUIApplication = XCUIApplication(),
        file: StaticString=#file,
        line: UInt=#line
    ) {
        self.assertExists(file: file, line: line)
        guard let currentValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value: \(self)")
            return
        }

        if currentValue == newValue {
            return
        }

        // Hit the delete key enough times to delete the current text
        var deleteString = ""
        for _ in currentValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }

        self.assertHittable(file: file, line: line)

        let lowerRightCorner = self.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.9))
        lowerRightCorner.tap()

        self.assertHasKeyboardFocus(app: app, file: file, line: line)
        self.typeText(deleteString + newValue + "\n")
    }

    // MARK: Keyboard Focus
    public var hasKeyboardFocus: Bool {
        let hasKeyboardFocus = (self.value(forKey: "hasKeyboardFocus") as? Bool) ?? false
        return hasKeyboardFocus
    }

    public func assertHasKeyboardFocus(
        waitPerAttempt: TimeInterval = WaitFor.defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = WaitFor.defaultTotalNumberOfAttempts,
        app: XCUIApplication = XCUIApplication(),
        file: StaticString=#file,
        line: UInt=#line
    ) {
        let element = self
        WaitFor.tryThrows(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts,
            file: file,
            line: line
        ) {
            if !element.hasKeyboardFocus {
                throw TestingError("Element \(element) does not have keyboard focus", element: element, app: app)
            }
        }
    }
}

// MARK: Checks & Assertions
extension XCUIElement {
    /*
     Hittable returns YES if the element exists and can be clicked, tapped, or pressed at its current location. It
     returns NO for an offscreen element in a scrollable view, even if the element would be scrolled into a hittable
     position by calling click tap, or another hit-point-related interaction method.
     */
    func assertHittable(
        waitPerAttempt: TimeInterval = WaitFor.defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = WaitFor.defaultTotalNumberOfAttempts,
        app: XCUIApplication = XCUIApplication(),
        file: StaticString=#file,
        line: UInt=#line
    ) {
        let element = self
        WaitFor.tryThrows(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts,
            file: file,
            line: line
        ) {
            if !element.waitForExistence(timeout: 0) {
                throw TestingError("Doesn't exist", element: self, app: app)
            }

            if !element.isHittable {
                throw TestingError("Not hittable", element: self, app: app)
            }
        }
    }

    public func assertExists(
        waitPerAttempt: TimeInterval = WaitFor.defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = WaitFor.defaultTotalNumberOfAttempts,
        app: XCUIApplication = XCUIApplication(),
        file: StaticString=#file,
        line: UInt=#line
    ) {
        let element = self
        WaitFor.tryThrows(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts,
            file: file,
            line: line
        ) {
            if !element.exists {
                throw TestingError("Does not exist", element: self, app: app)
            }
        }
    }

    public func checkExists(
        waitPerAttempt: TimeInterval = WaitFor.defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = WaitFor.defaultTotalNumberOfAttempts,
        app: XCUIApplication = XCUIApplication()
    ) -> Bool {
        let element = self
        return WaitFor.bool(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts
        ) {
            if !element.exists {
                throw TestingError("Does not exist", element: self, app: app)
            }
        }
    }

    public func assertNotExists(
        waitPerAttempt: TimeInterval = WaitFor.defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = WaitFor.defaultTotalNumberOfAttempts,
        app: XCUIApplication = XCUIApplication(),
        file: StaticString=#file,
        line: UInt=#line
    ) {
        let element = self
        WaitFor.tryThrows(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts,
            file: file,
            line: line
        ) {
            if element.exists {
                throw TestingError("Element \(element) exists", element: element, app: app)
            }
        }
    }
}

// MARK: Tapping on a CGPoint
// These are useful when the element you want to target is covered, or not hittable
// due to not being covered, not exposed to Accessibility, etc.
extension XCUIElement {

    // Note: XCUICoordinates are specific to a particular XCUIApplication.
    private func coordinate(from cgPoint: CGPoint) -> XCUICoordinate {
        let normalized = self.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let coordinate = normalized.withOffset(CGVector(dx: cgPoint.x, dy: cgPoint.y))
        return coordinate
    }

    public func tap(cgPoint: CGPoint) {
        let coordinate = self.coordinate(from: cgPoint)
        coordinate.tap()
    }

    public func tap(placeholder: Placeholder) {
        tap(cgPoint: placeholder.frame.center())
    }
}

// MARK: Nav Bar & Back Button
extension XCUIElement {
    public func tapBackButton(
        file: StaticString=#file,
        line: UInt=#line
    ) {
        WaitFor.tryThrows(file: file, line: line) {
            let query = self.navigationBars.buttons
            let backButton = query.firstMatch
            guard backButton.isHittable else {
                throw TestingError("Back button not hittable for query: \(query.debugDescription)")
            }
            backButton.tap()
        }
    }

    public func expectNavBar(
        title: String? = nil,
        file: StaticString=#file,
        line: UInt=#line
    ) {
        WaitFor.tryThrows(file: file, line: line) {
            let query = self.navigationBars
            let navBar = query.firstMatch
            guard navBar.exists else {
                throw TestingError("Nav bar does not exist for query: \(query.debugDescription)")
            }

            guard let title = title else {
                return
            }

            let actual = navBar.identifier
            guard title == actual else {
                throw TestingError("Expected nav bar title to be [\(title)], got [\(actual)] for query: \(query)")
            }
        }
    }

    public func expectNoNavBar(
        file: StaticString=#file,
        line: UInt=#line
    ) {
        WaitFor.tryThrows(file: file, line: line) {
            let query = self.navigationBars
            let navBar = query.firstMatch
            guard !navBar.exists else {
                throw TestingError("Nav bar exists!")
            }
        }
    }

    public func expectNoBackButton(
        file: StaticString=#file,
        line: UInt=#line
    ) {
        WaitFor.tryThrows(file: file, line: line) {
            let backButton = self.navigationBars.buttons["Back"]
            if backButton.exists {
                throw TestingError("Back Button exists!")
            }
        }
    }
}

// MARK: Array
extension Array where Element == XCUIElement {
    var placeholders: [Placeholder] {
        self.map {
            Placeholder($0)
        }
    }
}
