//
//  NetworkRequestInfoInteractor.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

final class NetworkRequestInfoInteractor {

    private let presenter: NetworkRequestInfoPresenterType
    private let model: ElementsHttpsModel
    private let type: NetworkRequestDetailAdvanceDataType

    private var potentialRewrite: ElementsRewriteRequest? {
        return NetworkMonitor.shared.getPotentialRewriteRequest(originModel: model, type: type)
    }

    init(presenter: NetworkRequestInfoPresenterType,
         model: ElementsHttpsModel,
         type: NetworkRequestDetailAdvanceDataType) {
        self.presenter = presenter
        self.model = model
        self.type = type
    }

    func keyUpdated(id: String, newKey: String) {
        switch type {
        case .queryParams:
            NetworkMonitor.shared.addRewriteRequest(
                originModel: model,
                command: .replaceQueryParamKey(id: id, newKey: newKey),
                completion: { [weak self] in
                    DispatchQueue.main.async {
                        self?.loadData()
                    }
                }
            )
        case .requestHeader:
            NetworkMonitor.shared.addRewriteRequest(
                originModel: model,
                command: .replaceHeaderKey(id: id, newKey: newKey)
            )
        default: break
        }
    }

    func valueUpdated(id: String, newValue: String) {
        switch type {
        case .queryParams:
            NetworkMonitor.shared.addRewriteRequest(
                originModel: model,
                command: .replaceQueryParamValue(id: id, newValue: newValue)
            )
        case .requestHeader:
            NetworkMonitor.shared.addRewriteRequest(
                originModel: model,
                command: .replaceHeaderValue(id: id, newValue: newValue)
            )
        default: break
        }
    }

    func resetAction(id: String) {
        var commandKey: RemoveRewriteRequestCommandType?
        var commandValue: RemoveRewriteRequestCommandType?
        switch type {
        case .queryParams:
            commandKey = .resetQueryParamKey(id: id)
            commandValue = .resetQueryParamValue(id: id)
        case .requestHeader:
            commandKey = .resetHeaderKey(id: id)
            commandValue = .resetHeaderValue(id: id)
        default:
            break
        }
        if let commandKey = commandKey, let commandValue = commandValue {
            NetworkMonitor.shared.removeRewriteRequest(originModel: model, command: commandKey)
            NetworkMonitor.shared.removeRewriteRequest(originModel: model, command: commandValue)
            loadData()
        }
    }
}

extension NetworkRequestInfoInteractor {

    func loadData() {
        var items: [NetworkRequestInfoModel]?
        switch type {
        case .queryParams:
            items = generateModelsForQueryParams()
        case .requestHeader:
            items = generateModelsForRequestHeader()
        case .responseHeader:
            items = generateModelsForResponseHeader()
        case .responseBody, .requestBody:
            break
        }
        if let items = items {
            presenter.presentDisplayData(
                items: items,
                keyUpdated: keyUpdated,
                valueUpdated: valueUpdated,
                resetAction: resetAction
            )
        }
    }

    private func generateModelsForQueryParams() -> [NetworkRequestInfoModel] {
        var result: [NetworkRequestInfoModel] = []
        let queryItems: [ElementsURLItem] = potentialRewrite?.latestResult.requestModel.queryItems ?? model.requestModel.queryItems
        let sortedParams = queryItems.sorted(by: { $0.name < $1.name })
        for param in sortedParams {
            result.append(NetworkRequestInfoModel(
                id: param.id,
                title: param.name,
                value: param.value,
                originTitle: param.originName,
                originValue: param.originValue
            ))
        }
        return result
    }

    private func generateModelsForRequestHeader() -> [NetworkRequestInfoModel] {
        var result: [NetworkRequestInfoModel] = []
        let headers = potentialRewrite?.latestResult.requestModel.headers ?? model.requestModel.headers
        let sortedDict = headers.sorted(by: { $0.name < $1.name })
        for param in sortedDict {
            result.append(NetworkRequestInfoModel(
                id: param.id,
                title: param.name,
                value: param.value,
                originTitle: param.originName,
                originValue: param.originValue)
            )
        }
        return result
    }

    private func generateModelsForResponseHeader() -> [NetworkRequestInfoModel] {
        return generateResponseHeaderModels(header: model.responseModel.headers ?? [:])
    }

    private func generateResponseHeaderModels(header: [AnyHashable: Any]) -> [NetworkRequestInfoModel] {
        var result: [NetworkRequestInfoModel] = []
        let sortedDict = header.sorted { (kvA, kvB) -> Bool in
            guard let keyAString = kvA.key as? String, let keyBString = kvB.key as? String else {
                return false
            }
            return keyAString < keyBString
        }
        for kv in sortedDict {
            guard let title = kv.key as? String, let value = kv.value as? String else {
                print("Failed to decode header")
                continue
            }
            result.append(NetworkRequestInfoModel(id: UUID().uuidString, title: title, value: value, originTitle: title, originValue: value))
        }
        return result
    }
}
