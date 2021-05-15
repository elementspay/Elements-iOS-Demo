//
//  NetworkRequestInfoPresenter.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import IGListKit
import UIKit

enum NetworkRequestInfoDisplayType {
    case originValue
    case overridedValue
}

struct NetworkRequestInfoModel {
    let id: String
    let title: String
    let value: String
    let originTitle: String
    let originValue: String
}

protocol NetworkRequestInfoPresenterOutput: class {
    func showPresentationData(models: [ListDiffable])
}

protocol NetworkRequestInfoPresenterType: class {
    func presentDisplayData(items: [NetworkRequestInfoModel],
                            keyUpdated: @escaping (String, String) -> Void,
                            valueUpdated: @escaping (String, String) -> Void,
                            resetAction: @escaping (String) -> Void)
}

final class NetworkRequestInfoPresenter: NetworkRequestInfoPresenterType {

    weak var output: NetworkRequestInfoPresenterOutput?

    func presentDisplayData(items: [NetworkRequestInfoModel],
                            keyUpdated: @escaping (String, String) -> Void,
                            valueUpdated: @escaping (String, String) -> Void,
                            resetAction: @escaping (String) -> Void) {
        var sectionData: [ListDiffable] = []
        for item in items {
            sectionData.append(NetworkRequestInfoPresentingModel(
                id: item.id,
                title: item.title,
                value: item.value,
                originTitle: item.originTitle,
                originValue: item.originValue,
                keyUpdated: keyUpdated,
                valueUpdated: valueUpdated,
                resetAction: resetAction)
            )
        }
        output?.showPresentationData(models: sectionData)
    }
}
