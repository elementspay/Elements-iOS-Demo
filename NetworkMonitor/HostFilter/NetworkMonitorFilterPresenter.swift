//
//  NetworkMonitorFilterPresenter.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 9/11/19.
//

import IGListKit
import UIKit

protocol NetworkMonitorFilterPresenterOutput: class {
    func showPresentationData(models: [ListDiffable])
}

protocol NetworkMonitorFilterPresenterType: class {
    func presentDisplayData(filters: [ElementsFilterContainer])
}

final class NetworkMonitorFilterPresenter: NetworkMonitorFilterPresenterType {

    weak var output: NetworkMonitorFilterPresenterOutput?

    func presentDisplayData(filters: [ElementsFilterContainer]) {
        var sectionData: [ListDiffable] = []
        for filter in filters {
            let presentingModel = ElementsFilterModel(item: filter)
            sectionData.append(presentingModel)
        }
        output?.showPresentationData(models: sectionData)
    }
}
