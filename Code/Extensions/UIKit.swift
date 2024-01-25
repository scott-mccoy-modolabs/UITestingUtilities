/*
 * Copyright © 2010 - 2024 Modo Labs Inc. All rights reserved.
 *
 * The license governing the contents of this file is located in the LICENSE
 * file located at the root directory of this distribution. If the LICENSE file
 * is missing, please contact sales@modolabs.com.
 *
 */

import UIKit

extension CGRect {
    func center() -> CGPoint {
        var ret = CGPoint()
        ret.x = self.origin.x + self.size.width / 2
        ret.y = self.origin.y + self.size.height / 2
        return ret
    }
}
