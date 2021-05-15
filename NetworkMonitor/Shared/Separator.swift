//
//  Separator.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/15/19.
//

import UIKit

final class Separator: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    static func create() -> Separator {
        let separator = Separator()
        separator.backgroundColor = ApplicationDependency.manager.theme.colors.separatorColor
        return separator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
