/*
 * Copyright © 2010 - 2024 Modo Labs Inc. All rights reserved.
 *
 * The license governing the contents of this file is located in the LICENSE
 * file located at the root directory of this distribution. If the LICENSE file
 * is missing, please contact sales@modolabs.com.
 *
 */

import Foundation

// Keystroke saver.
// Allows a function returning Result<Void, Error> to `return .success()`
extension Result where Success == Void {
    public static func success() -> Self { .success(()) }
}

extension Result {
    public func isSuccessful() -> Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    public func getError() -> Failure? {
        guard case let .failure(error) = self else {
            return nil
        }
        return error
    }
}
