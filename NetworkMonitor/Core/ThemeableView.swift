//
//  ThemeableView.swift
//  Alamofire
//
//  Created by Marvin Zhan on 11/13/19.
//

import UIKit

class ThemeableView: UIView, Themeable {

    override init(frame: CGRect) {
        super.init(frame: frame)
			ElementsTheme.manager.register(themeable: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(theme: ElementsTheme) {
    }
}

class ThemeableCollectionViewCell: UICollectionViewCell, Themeable {

    override init(frame: CGRect) {
        super.init(frame: frame)
        ElementsTheme.manager.register(themeable: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(theme: ElementsTheme) {
    }
}
