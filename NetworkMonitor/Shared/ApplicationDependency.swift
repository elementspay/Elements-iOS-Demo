//
//  ApplicationDependency.swift
//
//
//  Created by Marvin Zhan on 11/12/19.
//

import UIKit

final class ApplicationDependency {

    static let manager: ApplicationDependency = ApplicationDependency()

    var theme: ElementsTheme {
        return ElementsTheme.manager.activeTheme
    }

    private init() {
    }
}
