//
//  ElementsNavigationController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/15/19.
//

import UIKit

enum NavigationBarStyle {
    case mainTheme
    case largeGray
    case green
    case white
    case black
    case transparent
    case whiteTransparent
    case dark
}

protocol ElementsNavigationControllerType: UINavigationController {
    var navigationBarStyle: NavigationBarStyle { get set }
}

class ElementsNavigationController: UINavigationController, ElementsNavigationControllerType {

    var navigationBarStyle: NavigationBarStyle = .mainTheme {
        didSet {
            let theme = ApplicationDependency.manager.theme
            var titleColor: UIColor
            switch navigationBarStyle {
            case .transparent:
                navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationBar.shadowImage = UIImage()
                navigationBar.tintColor = ColorPlate.white
                navigationBar.isTranslucent = true
                titleColor = UIColor.clear
            case .white:
                navigationBar.setBackgroundImage(nil, for: .default)
                navigationBar.shadowImage = nil
                navigationBar.tintColor = theme.colors.themeColor
                navigationBar.isTranslucent = false
                navigationBar.barTintColor = ColorPlate.white
                navigationBar.layer.shadowColor = ColorPlate.black.cgColor
                navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
                navigationController?.navigationBar.layer.shadowRadius = 2.0
                navigationController?.navigationBar.layer.shadowOpacity = 1.0
                navigationController?.navigationBar.layer.masksToBounds = false
                titleColor = ColorPlate.black
            case .mainTheme:
                navigationBar.setBackgroundImage(nil, for: .default)
                navigationBar.shadowImage = nil
                navigationBar.tintColor = theme.colors.themeColor
                navigationBar.isTranslucent = false
                navigationBar.barTintColor = ColorPlate.white
                titleColor = ColorPlate.black
            case .dark:
                navigationBar.setBackgroundImage(nil, for: .default)
                navigationBar.shadowImage = nil
                navigationBar.tintColor = theme.colors.themeColor
                navigationBar.isTranslucent = false
                navigationBar.barTintColor = UIColor.init(hex: 0x040d14)!
                navigationBar.layer.shadowColor = ColorPlate.white.cgColor
                navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
                navigationController?.navigationBar.layer.shadowRadius = 2.0
                navigationController?.navigationBar.layer.shadowOpacity = 1.0
                navigationController?.navigationBar.layer.masksToBounds = false
                titleColor = ColorPlate.white
            default:
                navigationBar.setBackgroundImage(nil, for: .default)
                navigationBar.shadowImage = nil
                navigationBar.tintColor = theme.colors.themeColor
                navigationBar.isTranslucent = false
                navigationBar.barTintColor = theme.colors.backgroundColor
                titleColor = theme.colors.primaryTextColorLightCanvas
            }
            self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor, NSAttributedString.Key.font: FontPlate.heavy18]
        }
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            viewController.hidesBottomBarWhenPushed = false
        }

        super.pushViewController(viewController, animated: animated)
    }
}
