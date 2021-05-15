//
//  ThemePersistor.swift
//
//
//  Created by Marvin Zhan on 11/13/19.
//

import UIKit
/// A type that can be used to persist and retrieve theme identifiers
protocol ThemePersistor {

    /// The function to return the last used theme identifier
    func retreiveThemeId() -> String?

    /// The function to store the current theme identifier
    func saveThemeId(_ identifier: String)
}

extension UserDefaults: ThemePersistor {

    /// Private key for persisting the active Theme in UserDefaults
    private static let CurrentThemeIdentifier = "ThemeableCurrentThemeIdentifier"

    /// Retreive theme identifer from UserDefaults
    func retreiveThemeId() -> String? {
        return self.string(forKey: UserDefaults.CurrentThemeIdentifier)
    }

    /// Save theme identifer to UserDefaults
    func saveThemeId(_ identifier: String) {
        self.set(identifier, forKey: UserDefaults.CurrentThemeIdentifier)
    }
}
