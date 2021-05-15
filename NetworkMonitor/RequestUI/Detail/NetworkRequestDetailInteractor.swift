//
//  NetworkRequestDetailInteractor.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

final class NetworkRequestDetailInteractor {

    struct Constants {
        let exportText = "Export Request CURL"
    }

    private let presenter: NetworkRequestDetailPresenterType
    private let model: ElementsHttpsModel
    private let constants = Constants()

    init(presenter: NetworkRequestDetailPresenterType,
         model: ElementsHttpsModel) {
        self.presenter = presenter
        self.model = model
    }

    func handleExportButtonTapped() {
        let alert = generateExportOptionsAlertController()
        presenter.presentAlertController(alert: alert)
    }
}

extension NetworkRequestDetailInteractor {

    func loadData() {
        let basicInfos = generateBasicInfo()
        let advanceInfos = generateAdvanceInfo()
        presenter.presentDisplayData(items: basicInfos + advanceInfos)
    }

    private func generateBasicInfo() -> [NetworkRequestDetailItemModel] {
        let url = model.requestModel.requestURL
        let dataMap: [(String, String, UIColor?)] = [
            ("HOST", url?.host ?? String.notApplicable, nil),
            ("PATH", url?.path ?? String.notApplicable, nil),
            ("METHOD", model.requestModel.method?.rawValue ?? String.notApplicable, nil),
            ("STATUS CODE", model.responseModel.statusDisplay,
             model.responseModel.isSuccessful() ? ApplicationDependency.manager.theme.colors.themeColor: ApplicationDependency.manager.theme.colors.errorColor)
        ]
        return dataMap.map { (title, value, color) in
            return NetworkRequestDetailItemModel(
                displayType: .basic, title: title, value: value, valueColor: color ?? ApplicationDependency.manager.theme.colors.primaryTextColorLightCanvas
            )
        }
    }

    private func generateAdvanceInfo() -> [NetworkRequestDetailItemModel] {
        guard let method = model.requestModel.method else {
            return []
        }
        var dataMap: [(NetworkRequestDetailAdvanceDataType, String)] = [
            (NetworkRequestDetailAdvanceDataType.requestHeader, String(model.requestModel.headers.count)),
            (NetworkRequestDetailAdvanceDataType.responseHeader, String(model.responseModel.headers?.count ?? 0)),
            (NetworkRequestDetailAdvanceDataType.responseBody, (model.responseModel.responseBodyLength ?? 0).dataDisplayText)
        ]
        if method == .get {
            dataMap.insert((NetworkRequestDetailAdvanceDataType.queryParams, String(model.requestModel.queryItems.count)), at: 0)
        } else {
            dataMap.insert((NetworkRequestDetailAdvanceDataType.requestBody, (model.requestModel.requestBodyLength ?? 0).dataDisplayText), at: 1)
        }
        return dataMap.map { (type, value) in
            return NetworkRequestDetailItemModel(
                displayType: .advance,
                advanceDataType: type,
                title: type.rawValue,
                value: value,
                valueColor: ApplicationDependency.manager.theme.colors.primaryTextColorLightCanvas,
                selectedAction: { [weak self] type in
                    guard let `self` = self, let type = type else { return }
                    self.presenter.presentDetailData(model: self.model, type: type)
                }
            )
        }
    }
}

extension NetworkRequestDetailInteractor {

    private func generateExportOptionsAlertController() -> UIAlertController {
        let actionSheet = UIAlertController()
        actionSheet.addAction(UIAlertAction(title: constants.exportText, style: .default, handler: { [weak self] _ in
            self?.shareByText()
        }))

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("cancel_action", comment: ""), style: .cancel, handler: nil))
        return actionSheet
    }

    private func shareByText() {
        guard let textData = model.requestModel.requestCurl?.data(using: .utf8) else { return }
        guard let textURL = textData.dataToFile(fileName: "request_curl.txt") else {
            return
        }
        var filesToShare = [Any]()
        filesToShare.append(textURL)
        presentSharePage(items: filesToShare)
    }

    private func presentSharePage(items: [Any]) {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        presenter.presentAlertController(alert: controller)
    }
}
