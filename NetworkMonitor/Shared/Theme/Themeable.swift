//
//  Themeable.swift
//
//
//  Created by Marvin Zhan on 11/13/19.
//

import Foundation
import UIKit

/// A type that can be used to encapsulate theme values and variants
protocol Theme: Equatable {
    /// The unique identifier for the theme
    var identifier: String { get }

    /// An array of all the available variants for a theme
    static var variants: [Self] { get }

    /// The shared ThemeManager for a theme
    static var manager: ThemeManager<Self> { get }

    var colors: ColorSchema { get set }
    var fonts: FontSchema { get set }
    var images: ImageAssets { get set }
}

extension Theme {

    /// The default implmententation for equating two Themes using identifiers
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }

}

/// A type that observes Theme changes
protocol ThemeObservable: class {

    /// The method called when a theme is changed. You generally shouldn't need
    /// to implement this yourself
    func updateTheme()

}

/// A type that can have a Theme applied to it
protocol Themeable: ThemeObservable {

    /// The Theme that the type can use
    associatedtype ThemeType: Theme

    /// The function used to apply the Theme
    ///
    /// - Parameter theme: The Theme being applied to the type
    func apply(theme: ThemeType)

}

extension Themeable {

    /// The function for applying a theme after receiving an update.
    func updateTheme() {
        self.apply(theme: Self.ThemeType.manager.activeTheme)
    }
}
