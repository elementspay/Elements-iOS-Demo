//
//  SourceCodeTheme.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/13/19.
//

import UIKit

public protocol SourceCodeTheme: SyntaxColorTheme {
    func color(for syntaxColorType: SourceCodeTokenType) -> UIColor
}

extension SourceCodeTheme {

    public func globalAttributes() -> [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = font
        attributes[.foregroundColor] = ApplicationDependency.manager.theme.colors.primaryTextColorLightCanvas
        return attributes
    }

    public func attributes(for token: Token) -> [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key: Any]()
        if let token = token as? SimpleSourceCodeToken {
            attributes[.foregroundColor] = color(for: token.type)
        }
        return attributes
    }
}

public struct DefaultSourceCodeTheme: SourceCodeTheme {

    public let font = ApplicationDependency.manager.theme.fonts.secondaryTextFont
    public let backgroundColor = ApplicationDependency.manager.theme.colors.backgroundColor

    public func color(for syntaxColorType: SourceCodeTokenType) -> UIColor {
        switch syntaxColorType {
        case .plain:
            return .red
        case .number:
            return UIColor(hex: 0xAED0A4)!
        case .string:
            return UIColor(hex: 0xD88E73)!
        case .identifier:
            return UIColor(red: 20/255, green: 156/255, blue: 146/255, alpha: 1.0)
        case .keyword:
            return UIColor(red: 215/255, green: 0, blue: 143/255, alpha: 1.0)
        case .comment:
            return UIColor(red: 69.0/255.0, green: 187.0/255.0, blue: 62.0/255.0, alpha: 1.0)
        case .key:
            return ApplicationDependency.manager.theme.colors.textPadKeyColor
        case .boolean:
            return UIColor(hex: 0x3C9DDB)!
        }
    }
}
