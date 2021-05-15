//
//  TextPadInteractor.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import SwiftyJSON
import UIKit

public final class TextPadInteractor {

    struct Constants {
        let initialTextFont: UIFont = FontPlate.medium14
        let initialTextColor: UIColor = ColorPlate.darkGray
        let highlightedFont: UIFont = FontPlate.heavy18
			let highlightedBackgroundColor: UIColor = ColorPlate.lighterGray
			let highlightedTextColor: UIColor = ColorPlate.darkGreen

        let exportText = "Export Text"
        let exportJSON = "Export JSON"
    }

    private let presenter: TextPadPresenterType
    private let model: ElementsHttpsModel
    private let type: NetworkRequestDetailAdvanceDataType
    private var currentText: String = ""
    private var currentTerm: String = ""
    private var originText: String = ""
    private let constants = Constants()

    init(presenter: TextPadPresenterType,
         model: ElementsHttpsModel,
         type: NetworkRequestDetailAdvanceDataType) {
        self.presenter = presenter
        self.model = model
        self.type = type
    }

    func handleExportButtonTapped() {
        let alert = generateExportOptionsAlertController()
        presenter.presentAlertController(alert: alert)
    }
}

extension TextPadInteractor {

    func loadData() {
        let potentialRewrite = NetworkMonitor.shared.getPotentialRewriteRequest(originModel: model, type: type)
        if type == .responseBody {
            currentText = potentialRewrite?.latestResult.getResponseBody() ?? model.getResponseBody()
        }
        if type == .requestBody {
            currentText = potentialRewrite?.latestResult.getRequestBody() ?? model.getRequestBody()
        }
        if potentialRewrite != nil {
            presenter.presentRewriteToggleView(animated: false)
        }
        originText = currentText
        presenter.presentDisplayText(displayText: currentText)
    }

    func handleSearchPrevTerm() {
        guard !currentTerm.isEmpty else { return }
        presenter.presentPrevMatch(term: currentTerm)
    }

    func handleSearchNextTerm() {
        guard !currentTerm.isEmpty else { return }
        presenter.presentNextMatch(term: currentTerm)
    }

    func handleTextOverride(text: String) {
        currentText = text
        presenter.presentRewriteToggleView(animated: true)
    }

    func handleResetRequest() {
        presenter.dismissRewriteToggleView(animated: true)
        switch type {
        case .responseBody:
            NetworkMonitor.shared.removeRewriteRequest(originModel: model, command: .responseData)
        case .requestBody:
            NetworkMonitor.shared.removeRewriteRequest(originModel: model, command: .requestParamData)
        default:
            return
        }
        loadData()
    }

    func applyRewrite() {
        guard originText != currentText else { return }
        switch type {
        case .responseBody:
            guard let data = currentText.data(using: .utf8) else {
                return
            }
            NetworkMonitor.shared.addRewriteRequest(originModel: model, data: data, command: .responseData)
        case .requestBody:
            guard let data = currentText.data(using: .utf8) else {
                return
            }
            NetworkMonitor.shared.addRewriteRequest(originModel: model, data: data, command: .requestParamData)
        default:
            return
        }
    }

    func searchTerm(_ term: String) {
        currentTerm = term
        presenter.presentNextMatch(term: term)
    }
}

extension TextPadInteractor {

    private func generateExportOptionsAlertController() -> UIAlertController {
        let actionSheet = UIAlertController()
        actionSheet.addAction(UIAlertAction(title: constants.exportText, style: .default, handler: { [weak self] _ in
            self?.shareByText()
        }))

        actionSheet.addAction(UIAlertAction(title: constants.exportJSON, style: .default, handler: { [weak self] _ in
            self?.shareByJSON()
        }))

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("cancel_action", comment: ""), style: .cancel, handler: nil))
        return actionSheet
    }

    private func shareByText() {
        let textData = currentText.data(using: .utf8)
        guard let textURL = textData?.dataToFile(fileName: "body_text.txt") else {
            return
        }
        var filesToShare = [Any]()
        filesToShare.append(textURL)
        presentSharePage(items: filesToShare)
    }

    private func shareByJSON() {
        let textData = currentText.data(using: .utf8)
        guard let textURL = textData?.dataToFile(fileName: "body_text.json") else {
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
