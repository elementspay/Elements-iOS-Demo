//
//  Images.swift
//
//
//  Created by Marvin Zhan on 11/12/19.
//

import UIKit

final class ImageResources {
    static var searchIcon: UIImage {
        return UIImage(named: "search_icon") ?? UIImage()
    }

    static var rightTriangleGray: UIImage {
        return UIImage(named: "right_triangle_gray") ?? UIImage()
    }

    static var closeGreenIcon: UIImage {
        return UIImage(named: "close_green") ?? UIImage()
    }

    static var checkMarkGreen: UIImage {
        return UIImage(named: "check_green") ?? UIImage()
    }

    static var pullToRefreshIcon: UIImage {
        return UIImage(named: "pull_to_refresh") ?? UIImage()
    }

    static var loadingIcon: UIImage {
        return UIImage(named: "loading_icon") ?? UIImage()
    }

    static var settingsIcon: UIImage {
        return UIImage(named: "settings_icon") ?? UIImage()
    }

    static var logoCircleWhite: UIImage {
        return UIImage(named: "logo_circle_white") ?? UIImage()
    }
}

protocol ImageAssets {
    var searchIcon: UIImage { get }
    var rightTriangleIcon: UIImage { get }
    var closeIcon: UIImage { get }
    var checkMarkIcon: UIImage { get }
    var pullToRefreshIcon: UIImage { get }
    var loadingIcon: UIImage { get }
    var settingsIcon: UIImage { get }
}

final class LightThemeAssets: ImageAssets {
    var searchIcon: UIImage {
        return ImageResources.searchIcon
    }

    var rightTriangleIcon: UIImage {
        return ImageResources.rightTriangleGray
    }

    var closeIcon: UIImage {
        return ImageResources.closeGreenIcon
    }

    var checkMarkIcon: UIImage {
        return ImageResources.checkMarkGreen
    }

    var pullToRefreshIcon: UIImage {
        return ImageResources.pullToRefreshIcon
    }

    var loadingIcon: UIImage {
        return ImageResources.loadingIcon
    }

    var settingsIcon: UIImage {
        return ImageResources.settingsIcon
    }
}

final class DarkThemeAssets: ImageAssets {
    var searchIcon: UIImage {
        return ImageResources.searchIcon
    }

    var rightTriangleIcon: UIImage {
        return ImageResources.rightTriangleGray
    }

    var closeIcon: UIImage {
        return ImageResources.closeGreenIcon
    }

    var checkMarkIcon: UIImage {
        return ImageResources.checkMarkGreen
    }

    var pullToRefreshIcon: UIImage {
        return ImageResources.pullToRefreshIcon
    }

    var loadingIcon: UIImage {
        return ImageResources.loadingIcon
    }

    var settingsIcon: UIImage {
        return ImageResources.settingsIcon
    }
}
