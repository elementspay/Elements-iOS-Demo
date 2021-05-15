//
//  NetworkRequestDetailPresenter.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import IGListKit
import UIKit

enum NetworkRequestDetailItemType {
    case basic
    case advance
}

public enum NetworkRequestDetailAdvanceDataType: String {
    case queryParams = "Query Parameters"
    case requestHeader = "Request Headers"
    case requestBody = "Request Body"
    case responseHeader = "Response Headers"
    case responseBody = "Response Body"
}

final class NetworkRequestDetailItemModel {

    let displayType: NetworkRequestDetailItemType
    let advanceDataType: NetworkRequestDetailAdvanceDataType?
    let title: String
    let value: String
    let valueColor: UIColor
    let selectedAction: ((NetworkRequestDetailAdvanceDataType?) -> Void)?

    init(displayType: NetworkRequestDetailItemType,
         advanceDataType: NetworkRequestDetailAdvanceDataType? = nil,
         title: String,
         value: String,
         valueColor: UIColor,
         selectedAction: ((NetworkRequestDetailAdvanceDataType?) -> Void)? = nil) {
        self.displayType = displayType
        self.advanceDataType = advanceDataType
        self.title = title
        self.value = value
        self.valueColor = valueColor
        self.selectedAction = selectedAction
    }
}

protocol NetworkRequestDetailPresenterOutput: class {
    func showPresentationData(models: [ListDiffable])
    func showDetailData(model: ElementsHttpsModel, type: NetworkRequestDetailAdvanceDataType)
    func showAlertController(alert: UIViewController)

}

protocol NetworkRequestDetailPresenterType: class {
    func presentDisplayData(items: [NetworkRequestDetailItemModel])
    func presentDetailData(model: ElementsHttpsModel, type: NetworkRequestDetailAdvanceDataType)
    func presentAlertController(alert: UIViewController)
}

final class NetworkRequestDetailPresenter: NetworkRequestDetailPresenterType {

    weak var output: NetworkRequestDetailPresenterOutput?

    func presentDisplayData(items: [NetworkRequestDetailItemModel]) {
        var sectionData: [ListDiffable] = []
        for item in items {
            switch item.displayType {
            case .basic:
                sectionData.append(NetworkRequestDetailBasicInfoModel(item: item))
            case .advance:
                sectionData.append(NetworkRequestDetailAdvanceInfoModel(item: item))
            }
        }
        output?.showPresentationData(models: sectionData)
    }

    func presentDetailData(model: ElementsHttpsModel, type: NetworkRequestDetailAdvanceDataType) {
        output?.showDetailData(model: model, type: type)
    }

    func presentAlertController(alert: UIViewController) {
        output?.showAlertController(alert: alert)
    }
}
