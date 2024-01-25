//
//  UIInterruptionMonitorHelper.swift
//  UITestingUtilities
//
//  Created by smccoy on 1/24/24.
//

import Foundation

// MARK: UIInterruptionMonitor Handling
public protocol UIInterruptionMonitorSelection {
    var alertLabelToken: String {get}
    var rawValue: String {get}
}

// Prompt to allow Notifications
public enum NotificationAlert: String, UIInterruptionMonitorSelection {
    public var alertLabelToken: String {
        return "Notifications"
    }

    case allow = "Allow"
    case dontAllow = "Don’t Allow" // Note the use of ’
}

// Prompt to allow access to Location Services
public enum LocationAlert: String, UIInterruptionMonitorSelection {

    public var alertLabelToken: String {
        return "location"
    }

    case allowOnce = "Allow Once"
    case allowWhileUsingApp = "Allow While Using App"
    case dontAllow = "Don’t Allow" // Note the use of ’
}

// Prompt to allow FaceId
public enum FaceIdAlert: String, UIInterruptionMonitorSelection {
    public var alertLabelToken: String {
        return "Face ID"
    }

    case dontAllow = "Don’t Allow" // Note the use of ’
    case allow = "OK"
}
