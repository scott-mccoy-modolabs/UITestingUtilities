/*
 * Copyright © 2010 - 2024 Modo Labs Inc. All rights reserved.
 *
 * The license governing the contents of this file is located in the LICENSE
 * file located at the root directory of this distribution. If the LICENSE file
 * is missing, please contact sales@modolabs.com.
 *
 */

import XCTest

// MARK: waitFor
public enum WaitFor {

    public static let defaultWaitPerAttempt: TimeInterval = 3.0
    public static let defaultTotalNumberOfAttempts = 5

    // Generic wait-until-true checker.
    // Used by other implementations of WaitFor
    public static func result<T>(
        waitPerAttempt: TimeInterval = defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = defaultTotalNumberOfAttempts,
        attemptNumber: Int=1,
        _ attempt: () throws -> T
    ) -> Result<T, TestingError> {

        // There's at least 1 attempt remaining
        if totalNumberOfAttempts <= 0 {
            return .failure(TestingError("totalNumberOfAttempts <= 0"))
        }

        do {
            return .success(try attempt())
        } catch let error as TestingError {
            if attemptNumber >= totalNumberOfAttempts {
                return .failure(error)
            }

            Thread.sleep(forTimeInterval: waitPerAttempt)
            return result(
                waitPerAttempt: waitPerAttempt,
                totalNumberOfAttempts: totalNumberOfAttempts,
                attemptNumber: attemptNumber+1,
                attempt
            )

        } catch {
            return .failure(TestingError("Unexpected error: \(error.localizedDescription)"))
        }
    }

    // Most commonly used version.
    // Automatically records a failure instead of returning Result
    public static func tryThrows(
        waitPerAttempt: TimeInterval = defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = defaultTotalNumberOfAttempts,
        attemptNumber: Int=1,
        file: StaticString=#file,
        line: UInt=#line,
        _ attempt: () throws -> Void
    ) {
        let result = result(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts,
            attemptNumber: attemptNumber,
            attempt
        )

        result.getError()?.fail(file: file, line: line)
    }

    // Returns Bool instead of Result
    public static func bool(
        waitPerAttempt: TimeInterval = defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = defaultTotalNumberOfAttempts,
        attemptNumber: Int=1,
        _ attempt: () throws -> Void
    ) -> Bool {
        let result: Result<Void, TestingError> = result(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts,
            attemptNumber: attemptNumber+1,
            attempt
        )
        return result.isSuccessful()
    }
}
