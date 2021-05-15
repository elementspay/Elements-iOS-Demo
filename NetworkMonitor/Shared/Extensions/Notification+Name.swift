//
//  Notification+Name.swift
//
//
//  Created by Marvin Zhan on 12/8/19.
//

import UIKit

protocol NotificationName {
    var name: Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self: NotificationName {
    var name: Notification.Name {
        get {
            return Notification.Name(self.rawValue)
        }
    }
}

enum NetworkMonitorNotifications: String, NotificationName {
    case newRequestAdded
    case requestCompleted
}
