//
//  Colors.swift
//
//
//  Created by Marvin Zhan on 11/12/19.
//

import UIKit

final class ColorPlate {

    static var white: UIColor {
        return UIColor.white
    }

    static var black: UIColor {
        return UIColor.black
    }

    static var lightBlack: UIColor {
        return UIColor(hex: 0x1D252B)!
    }

    static var blackPearl: UIColor {
        return #colorLiteral(red: 0.0156862745, green: 0.05098039215, blue: 0.07843137254, alpha: 1)
    }

    static var clear: UIColor {
        return UIColor.clear
    }

    static var red: UIColor {
        return #colorLiteral(red: 0.8862745098, green: 0.34117647058, blue: 0.29803921568, alpha: 1)
    }

    ///rgba(5, 197, 0, 1)
    static var darkGreen: UIColor {
        return #colorLiteral(red: 0.01960784314, green: 0.7725490196, blue: 0, alpha: 1)
    }

    ///rgba(167, 167, 170, 1)
    static var gray: UIColor {
        return #colorLiteral(red: 0.6549019608, green: 0.6549019608, blue: 0.6666666667, alpha: 1)
    }

    ///rgba(68, 74, 87, 1)
    static var darkestGray: UIColor {
        return #colorLiteral(red: 0.2666666667, green: 0.2901960784, blue: 0.3411764706, alpha: 1)
    }

    ///rgba(139, 139, 139, 1)
    static var darkGray: UIColor {
        return #colorLiteral(red: 0.5450980392, green: 0.5450980392, blue: 0.5450980392, alpha: 1)
    }

    static var darkerGray: UIColor {
        return UIColor(hex: 0x596569)!
    }

    ///rgba(233, 233, 233, 1)
    static var lighterGray: UIColor {
        return #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9137254902, alpha: 1)
    }

    ///rgba(247, 247, 247, 1)
    static var lightestGray: UIColor {
        return #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    }

    static var lightSeparatorGray: UIColor {
        return #colorLiteral(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
    }

    static var redError: UIColor {
        return #colorLiteral(red: 1, green: 0.4392156863, blue: 0.3450980392, alpha: 1)
    }

    static var softOrange: UIColor {
        return #colorLiteral(red: 0.93725490196, green: 0.50588235294, blue: 0.21176470588, alpha: 1)
    }
}

protocol ColorSchema {
    var themeColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var shadowColor: UIColor { get }
    var darkCanvasBackgroundColor: UIColor { get }
    var lightBackgroundColor: UIColor { get }
    var lightCanvasColor: UIColor { get }
    var darkCanvasColor: UIColor { get }
    var primaryTextColorDarkCanvas: UIColor { get }
    var secondaryTextColorDarkCanvas: UIColor { get }
    var primaryTextColorLightCanvas: UIColor { get }
    var secondaryTextColorLightCanvas: UIColor { get }
    var errorColor: UIColor { get }
    var lightTextColor: UIColor { get }
    var separatorColor: UIColor { get }
    var textPadColor: UIColor { get }
    var textPadKeyColor: UIColor { get }
}

final class LightThemeColors: ColorSchema {

    var backgroundColor: UIColor {
        return ColorPlate.white
    }

    var shadowColor: UIColor {
        return ColorPlate.black
    }

    var darkCanvasBackgroundColor: UIColor {
        return ColorPlate.lightestGray
    }

    var lightBackgroundColor: UIColor {
        return ColorPlate.lightestGray
    }

    var lightCanvasColor: UIColor {
        return ColorPlate.white
    }

    var darkCanvasColor: UIColor {
        return ColorPlate.darkGreen
    }

    var themeColor: UIColor {
        return ColorPlate.darkGreen
    }

    var primaryTextColorDarkCanvas: UIColor {
        return ColorPlate.white
    }

    var secondaryTextColorDarkCanvas: UIColor {
        return ColorPlate.white
    }

    var primaryTextColorLightCanvas: UIColor {
        return ColorPlate.darkestGray
    }

    var secondaryTextColorLightCanvas: UIColor {
        return ColorPlate.darkGray
    }

    var lightTextColor: UIColor {
        return ColorPlate.gray
    }

    var separatorColor: UIColor {
        return ColorPlate.lightSeparatorGray
    }

    var errorColor: UIColor {
        return ColorPlate.redError
    }

    var textPadColor: UIColor {
        return ColorPlate.darkGray
    }

    var textPadKeyColor: UIColor {
        return ColorPlate.darkestGray
    }
}

final class DarkThemeColors: ColorSchema {

    var backgroundColor: UIColor {
        return ColorPlate.blackPearl
    }

    var shadowColor: UIColor {
        return ColorPlate.darkGreen
    }

    var darkCanvasBackgroundColor: UIColor {
        return ColorPlate.blackPearl
    }

    var lightBackgroundColor: UIColor {
        return ColorPlate.white.withAlphaComponent(0.05)
    }

    var lightCanvasColor: UIColor {
        return ColorPlate.blackPearl
    }

    var darkCanvasColor: UIColor {
        return ColorPlate.darkGreen
    }

    var themeColor: UIColor {
        return ColorPlate.darkGreen
    }

    var primaryTextColorDarkCanvas: UIColor {
        return ColorPlate.white
    }

    var primaryTextColorLightCanvas: UIColor {
        return ColorPlate.white
    }

    var secondaryTextColorDarkCanvas: UIColor {
        return ColorPlate.white
    }

    var secondaryTextColorLightCanvas: UIColor {
        return ColorPlate.darkerGray
    }

    var lightTextColor: UIColor {
        return ColorPlate.gray
    }

    var separatorColor: UIColor {
        return ColorPlate.white.withAlphaComponent(0.05)
    }

    var errorColor: UIColor {
        return ColorPlate.redError
    }

    var textPadColor: UIColor {
        return UIColor(hex: 0xD2D2D2)!
    }

    var textPadKeyColor: UIColor {
        return UIColor(hex: 0x89DDFF)!
    }
}
