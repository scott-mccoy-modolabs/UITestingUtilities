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

open class AbstractUITestCase: XCTestCase {
    public let app = XCUIApplication()
    public let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
    public let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    public let webViewStaticTexts = XCUIApplication().webViews.staticTexts
    
    open override func setUp() {
        XCTFail("Override this in a subclass")
    }
    
    open override func tearDown() {
        app.terminate()
    }
}



extension AbstractUITestCase {

    public func uiInterruptionMonitor(
        selections: [UIInterruptionMonitorSelection],
        file: StaticString=#file,
        line: UInt=#line
    ) {
        // Sleep briefly to allow the interrupting alert time to appear
        Thread.sleep(forTimeInterval: 3.0)

        var numInvocations = 0
        let uiInterruptionMonitor = addUIInterruptionMonitor(
            withDescription: "System Dialog"
        ) { (alert) -> Bool in

            // Tapping and not hitting a button that dismisses the alert can re-invoke the interruption
            // monitor, causing a loop.
            numInvocations += 1
            if numInvocations > 10 {
                XCTFail("uiInterruptionMonitor invocations exceeded limit of 10", file: file, line: line)
                return true
            }

            for selection in selections where alert.label.contains(selection.self.alertLabelToken) {
                alert.buttons.tap(label: selection.rawValue, file: file, line: line)
                return true
            }

            return true
        }

        // harmless UI interaction to force the UIInterruptionMonitor
        app.swipeDown()

        // Remove the now-useless monitor
        removeUIInterruptionMonitor(uiInterruptionMonitor)
    }
}

// MARK: Biometrics & Passcode
public enum SpringboardAuthentication: CaseIterable {

    case faceId
    case passcode

    static func getCurrent(
        waitPerAttempt: TimeInterval = 3.0,
        totalNumberOfAttempts: Int = 2
    ) -> Result<Self, TestingError> {
        return WaitFor.result(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts
        ) {
            for myCase in Self.allCases where myCase.isActive() {
                return myCase
            }

            throw TestingError("Unable to determine SpringboardAuthentication")
        }
    }

    func isActive() -> Bool {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        switch self {
        case .faceId:
            return springboard.staticTexts["Face ID"].exists

        case .passcode:
            return springboard.staticTexts["Enter iPhone passcode for “Kurogo-iOS-Sandbox”"].exists
        }
    }
}

extension AbstractUITestCase {
    public func handleBiometricOrPasscodePrompt(
        expected: SpringboardAuthentication? = nil,
        shouldAuthenticate: Bool = true,
        file: StaticString=#file,
        line: UInt=#line
    ) {
        // Fetch the kind of SpringBoardAuthentication currently visible, if any
        let springboardAuthentication = try? SpringboardAuthentication.getCurrent().get()

        // Validate
        XCTAssertEqual(
            expected,
            springboardAuthentication,
            // swiftlint:disable:next line_length
            "Expected \(String(describing: expected)), got \(String(describing: springboardAuthentication)). app: \(app.debugDescription), springboard: \(springboard.debugDescription)",
            file: file,
            line: line
        )

        // Bail if there's no authentication to do
        guard let springboardAuthentication else {
            return
        }

        // Pass or fail the authentication challenge as instructed by shouldAuthenticate
        switch springboardAuthentication {

        case .faceId:

            if shouldAuthenticate {
                Biometrics.successfulAuthentication()
            } else {
                Biometrics.unsuccessfulAuthentication()
            }

        case .passcode:
            // If you enter any password, authentication succeeds.
            // If you enter empty string, authentication fails.
            let text = shouldAuthenticate ? "test" : ""

            springboard
                .secureTextFields
                .firstMatch
                .clearAndEnterText(
                    text,
                    file: file,
                    line: line
                )
        }
    }
}

// MARK: Utility
extension AbstractUITestCase {
    public func screenshot(name: String? = nil) {
        // Attach screenshot
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        attachment.name = name
        add(attachment)
    }
}
