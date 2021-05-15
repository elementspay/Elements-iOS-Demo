//
//  ApplicationSettings.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/15/19.
//

import UIKit

final class ApplicationSettings {

    private struct Constants {
        static let enableRewrite = "enableRewrite"
        static let enableAutoRefresh = "enableAutoRefresh"
    }

    static var enabledRewrite: Bool {
        get {
            if UserDefaults.standard.object(forKey: Constants.enableRewrite) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: Constants.enableRewrite)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.enableRewrite)
        }
    }

    static var enabledAutoRefresh: Bool {
        get {
            if UserDefaults.standard.object(forKey: Constants.enableAutoRefresh) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: Constants.enableAutoRefresh)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.enableAutoRefresh)
        }
    }
}
