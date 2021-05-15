//
//  SyntaxColorTheme.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/13/19.
//

import CoreGraphics
import UIKit

public protocol SyntaxColorTheme {
    var font: UIFont { get }
    var backgroundColor: UIColor { get }

    func globalAttributes() -> [NSAttributedString.Key: Any]
    func attributes(for token: Token) -> [NSAttributedString.Key: Any]
}

public struct ThemeInfo {

    let theme: SyntaxColorTheme
    /// Width of a space character in the theme's font.
    /// Useful for calculating tab indent size.
    let spaceWidth: CGFloat
}
