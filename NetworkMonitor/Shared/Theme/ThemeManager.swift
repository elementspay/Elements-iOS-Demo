//
//  ThemeManager.swift
//
//
//  Created by Marvin Zhan on 11/13/19.
//

import Foundation
import UIKit

/// The class for managing Theme state and persistence
final class ThemeManager<T: Theme> {

    /// The store for persisting the active theme
    private let persistor: ThemePersistor

    /// A list of observers to be notified when the theme changes
    var observers: NSHashTable<AnyObject> = NSHashTable.weakObjects()

    /// The currently active theme
    var activeTheme: T {
        didSet {
            self.updateObservers()

            // save theme for use next launch
            self.persistor.saveThemeId(self.activeTheme.identifier)
        }

    }

    /// Initialize a ThemeManager with a default Theme. The manager will use the
    /// last used theme and fallback to the default if one isn't available or if
    /// `forceDefault` was used.
    ///
    /// - Parameter default:      The default theme to use and fall back to
    /// - Parameter persistor:    The store for persisting the active theme
    /// - Parameter forceDefault: Force the manager to use the default instead of
    ///                           loading the last used from storage
    init(default theme: T, persistor: ThemePersistor = UserDefaults.standard, forceDefault: Bool = false) {
        self.persistor = persistor

        guard forceDefault == false, let themeId = self.persistor.retreiveThemeId() else {
            self.activeTheme = theme
            return
        }

        let themeWithId: T? = T.variants.first(where: { theme in
            theme.identifier == themeId
        })

        self.activeTheme = themeWithId ?? theme
    }

    /// Internal function for running the theming functions with a given Theme
    func updateObservers() {
        for item in self.observers.allObjects {
            if let observer = item as? ThemeObservable {
                observer.updateTheme()
            }
        }
    }

    /// Register a Themeable object to receive Theme updates
    ///
    /// - Parameter themeable: The object wanting to receive updates
    func register<Item: Themeable>(themeable: Item) where Item.ThemeType == T {
        themeable.updateTheme()
        self.observers.add(themeable)
    }
}
