//
//  SettingsPresenter.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/15/19.
//

import IGListKit
import UIKit

protocol SettingsPresenterOutput: class {
    func showPresentationData(models: [ListDiffable])
}

protocol SettingsPresenterType: class {
    func presentDisplayData(settings: [ElementsFilterContainer])
}

final class SettingsPresenter: SettingsPresenterType {

    weak var output: SettingsPresenterOutput?

    func presentDisplayData(settings: [ElementsFilterContainer]) {
        var sectionData: [ListDiffable] = []
        for setting in settings {
            let presentingModel = ElementsFilterModel(item: setting)
            sectionData.append(presentingModel)
        }
        output?.showPresentationData(models: sectionData)
    }
}
