//
//  Theme.swift
//  Alamofire
//
//  Created by Marvin Zhan on 11/12/19.
//

import UIKit

enum ElementsThemeType {
    case light
    case dark
}

final class ElementsTheme: Theme {

    let type: ElementsThemeType
    let identifier: String
    var uiPaddingUnit: CGFloat = 8
    var themeChangeAnimDuration: TimeInterval = 0.3
    var colors: ColorSchema
    var fonts: FontSchema
    var images: ImageAssets

    static let light = ElementsTheme(
        identifier: "elements.light_theme",
        type: .light,
        colors: LightThemeColors(),
        fonts: LightThemeFonts(),
        images: LightThemeAssets()
    )

    static let dark = ElementsTheme(
        identifier: "elements.dark_theme",
        type: .dark,
        colors: DarkThemeColors(),
        fonts: DarkThemeFonts(),
        images: DarkThemeAssets()
    )

    // Expose the available theme variants
    static let variants: [ElementsTheme] = [.light, .dark]

    // Expose the shared theme manager
    static let manager = ThemeManager<ElementsTheme>(default: .dark)

    init(identifier: String,
         type: ElementsThemeType,
         colors: ColorSchema = LightThemeColors(),
         fonts: FontSchema = LightThemeFonts(),
         images: ImageAssets = LightThemeAssets()) {
        self.identifier = identifier
        self.type = type
        self.colors = colors
        self.fonts = fonts
        self.images = images
    }
}
