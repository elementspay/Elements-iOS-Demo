//
//  NetworkMonitorPresenter.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/11/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import IGListKit
import UIKit

enum NetworkResponseSpeedLevel {
    case fast
    case med
    case slow

    var dispalyColor: UIColor {
        switch self {
        case .fast:
            return ColorPlate.darkestGray
        case .med:
            return ColorPlate.softOrange
        case .slow:
            return ColorPlate.red
        }
    }

    static func generate(speed: Float) -> NetworkResponseSpeedLevel {
        if speed < 0.25 {
            return fast
        } else if speed >= 0.25 && speed < 0.5 {
            return med
        } else {
            return slow
        }
    }
}

protocol NetworkMonitorPresenterOutput: class {
    func showAlertController(alert: UIAlertController)
    func showPresentationData(models: [ListDiffable])
    func showRequestDetail(model: ElementsHttpsModel)
    func showHostFilterModule(currentFilters: [ElementsFilterContainer]?)
    func showSettingsModule(currentSettings: [ElementsFilterContainer]?)
}

protocol NetworkMonitorPresenterType: class {
    func presentAlertController(alert: UIAlertController)
    func presentDisplayData(titleItems: [NetworkStatisticsItem],
                            networkModels: [ElementsHttpsModel],
                            modelSelected: ((String) -> Void)?)
    func presentRequestDetail(model: ElementsHttpsModel)
    func presentHostFilterModule(currentFilters: [ElementsFilterContainer]?)
    func presentSettingsModule(currentSettings: [ElementsFilterContainer]?)
}

final class NetworkMonitorPresenter: NetworkMonitorPresenterType {

    weak var output: NetworkMonitorPresenterOutput?

    func presentDisplayData(titleItems: [NetworkStatisticsItem],
                            networkModels: [ElementsHttpsModel],
                            modelSelected: ((String) -> Void)?) {
        var sectionData: [ListDiffable] = []
        sectionData.append(NetworkStatisticsItemsModel(items: titleItems.map {
            NetworkStatisticsItemModel(title: $0.displayTitle, value: $0.value)
        }))
        for model in networkModels {
            let statusColor = model.responseModel.isSuccessful() ? ColorPlate.darkGreen : ColorPlate.red
            let speed = NetworkResponseSpeedLevel.generate(speed: model.timeInterval ?? 0)
            sectionData.append(NetworkRequestDisplayModel(
                id: model.identifier,
                status: model.responseModel.statusDisplay,
                statusColor: statusColor,
                method: model.requestModel.method?.rawValue ?? String.loadingText,
                path: model.requestModel.requestURL?.path ?? String.loadingText,
                time: model.requestModel.requestTime ?? String.loadingText,
                responseTime: model.responseTimeInterval,
                responseTimeColor: speed.dispalyColor,
                isOverrided: NetworkMonitor.shared.isRequestBeingRewrote(model: model),
                requestSelected: modelSelected
            ))
        }
        output?.showPresentationData(models: sectionData)
    }

    func presentRequestDetail(model: ElementsHttpsModel) {
        output?.showRequestDetail(model: model)
    }

    func presentAlertController(alert: UIAlertController) {
        output?.showAlertController(alert: alert)
    }

    func presentHostFilterModule(currentFilters: [ElementsFilterContainer]?) {
        output?.showHostFilterModule(currentFilters: currentFilters)
    }

    func presentSettingsModule(currentSettings: [ElementsFilterContainer]?) {
        output?.showSettingsModule(currentSettings: currentSettings)
    }
}
