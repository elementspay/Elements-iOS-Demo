//
//  Fonts.swift
//
//
//  Created by Marvin Zhan on 11/12/19.
//

import UIKit

class FontPlate {

    enum FontStyle {
        case regular
        case heavy
        case medium
        case light
    }

    static var regular10: UIFont {
        return font(style: .regular, size: 10)
    }

    static var regular12: UIFont {
        return font(style: .regular, size: 12)
    }

    static var regular14: UIFont {
        return font(style: .regular, size: 14)
    }

    static var regular16: UIFont {
        return font(style: .regular, size: 16)
    }

    static var medium12: UIFont {
        return font(style: .medium, size: 12)
    }

    static var medium14: UIFont {
        return font(style: .medium, size: 14)
    }

    static var medium15: UIFont {
        return font(style: .medium, size: 15)
    }

    static var medium16: UIFont {
        return font(style: .medium, size: 16)
    }

    static var medium18: UIFont {
        return font(style: .medium, size: 18)
    }

    static var medium20: UIFont {
        return font(style: .medium, size: 20)
    }

    static var heavy10: UIFont {
        return font(style: .heavy, size: 10)
    }

    static var heavy12: UIFont {
        return font(style: .heavy, size: 12)
    }

    static var heavy14: UIFont {
        return font(style: .heavy, size: 14)
    }

    static var heavy16: UIFont {
        return font(style: .heavy, size: 16)
    }

    static var heavy18: UIFont {
        return font(style: .heavy, size: 18)
    }

    static var heavy20: UIFont {
        return font(style: .heavy, size: 20)
    }

    static var heavy24: UIFont {
        return font(style: .heavy, size: 24)
    }

    static var heavy30: UIFont {
        return font(style: .heavy, size: 30)
    }

    static func font(size: CGFloat) -> UIFont {
        return font(style: .regular, size: size)
    }

    private static func font(style: FontStyle, size: CGFloat) -> UIFont {
        var name: String
        switch style {
        case .heavy:
            name = "Avenir-Heavy"
        case .regular:
            name = "Avenir-Book"
        case .medium:
            name = "Avenir-Medium"
        case .light:
            name = "Avenir-Light"
        }
        return UIFont(name: name, size: size)!
    }
}

protocol FontSchema {
    var primaryTextFont: UIFont { get }
    var boldPrimaryTextFont: UIFont { get }
    var secondaryTextFont: UIFont { get }
    var lightSecondaryTextFont: UIFont { get }
    var largeTextFont: UIFont { get }
    var boldLargeTextFont: UIFont { get }
}

final class LightThemeFonts: FontSchema {
    var primaryTextFont: UIFont {
        return FontPlate.medium16
    }

    var boldPrimaryTextFont: UIFont {
        return FontPlate.heavy16
    }

    var secondaryTextFont: UIFont {
        return FontPlate.medium14
    }

    var lightSecondaryTextFont: UIFont {
        return FontPlate.regular14
    }

    var largeTextFont: UIFont {
        return FontPlate.medium20
    }

    var boldLargeTextFont: UIFont {
        return FontPlate.heavy20
    }
}

final class DarkThemeFonts: FontSchema {
    var primaryTextFont: UIFont {
        return FontPlate.medium16
    }

    var boldPrimaryTextFont: UIFont {
        return FontPlate.heavy16
    }

    var secondaryTextFont: UIFont {
        return FontPlate.medium14
    }

    var lightSecondaryTextFont: UIFont {
        return FontPlate.regular14
    }

    var largeTextFont: UIFont {
        return FontPlate.medium20
    }

    var boldLargeTextFont: UIFont {
        return FontPlate.heavy20
    }
}
