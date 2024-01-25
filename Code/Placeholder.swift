/*
 * Copyright © 2010 - 2024 Modo Labs Inc. All rights reserved.
 *
 * The license governing the contents of this file is located in the LICENSE
 * file located at the root directory of this distribution. If the LICENSE file
 * is missing, please contact sales@modolabs.com.
 *
 */

import UIKit
import XCTest

// Interacting directly with XCUIElements is often very slow.
// This struct acts as a proxy for the purposes of simple UI Testing actions like looking for
// the frame of an element with a particular label.
public struct Placeholder {
    var label: String
    var frame: CGRect
}

public extension Placeholder {
    init (_ xcuiElement: XCUIElement) {
        self.init(label: xcuiElement.label, frame: xcuiElement.frame)
    }
}
