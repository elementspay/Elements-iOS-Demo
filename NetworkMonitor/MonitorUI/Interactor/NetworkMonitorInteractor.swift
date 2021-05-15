//
//  NetworkMonitorInteractor.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/11/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

final class NetworkStatisticsItem {

    let displayTitle: String
    let value: String

    init(displayTitle: String, value: String) {
        self.displayTitle = displayTitle
        self.value = value
    }
}

public final class NetworkMonitorInteractor {

    struct Constants {
        let sortByStartTime = "Sort by start time"
        let sortByResponseTime = "Sort by response time"
    }

    private let presenter: NetworkMonitorPresenterType
    private var sortOrder: ComparisonResult = .orderedDescending
    private var sortOption: NetworkModelSortOption = .startTime

    private var currentFilters: [ElementsFilterContainer]?
    private var currentSettings: [ElementsFilterContainer]?

    private let constants = Constants()

    init(presenter: NetworkMonitorPresenterType) {
        self.presenter = presenter
        if ApplicationSettings.enabledAutoRefresh {
            registerNotifications()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func handleSortButtonTapped() {
        let alert = generateSortOptionsAlertController()
        presenter.presentAlertController(alert: alert)
    }

    func handleHostFilter() {
        presenter.presentHostFilterModule(currentFilters: currentFilters)
    }

    func handleClearData() {
        NetworkMonitor.shared.clearModels {
            DispatchQueue.main.async {
                self.loadData()
            }
        }
    }

    func handleSettingsAction() {
        presenter.presentSettingsModule(currentSettings: currentSettings)
    }

    func applyFilters(filters: [ElementsFilterContainer]) {
        currentFilters = filters
        loadData()
    }

    func applySettings(settings: [ElementsFilterContainer]) {
        currentSettings = settings
        for setting in settings {
            guard let section = SettingsSection(rawValue: setting.section.displayID) else {
                continue
            }
            if section == .themeSettings,
                let selectedItem = setting.selectedItems.first,
                let type = SupportedThemeType(rawValue: selectedItem) {
                ElementsTheme.manager.activeTheme = type == .dark ? .dark : .light
            }
            if section == .enabledRewrite {
                ApplicationSettings.enabledRewrite = setting.selectedItems.count == 1
            }
            if section == .enabledAutoRefresh {
                let enabled = setting.selectedItems.count == 1
                if ApplicationSettings.enabledAutoRefresh != enabled {
                    if enabled {
                        registerNotifications()
                    } else {
                        NotificationCenter.default.removeObserver(self)
                    }
                }
                ApplicationSettings.enabledAutoRefresh = enabled
            }
        }
    }

    func autoCompleteRequests(searchTerm: String) {
        guard !searchTerm.isEmpty else {
            loadData()
            return
        }
        let networkModels = obtainValidRequestModels()
        var result: [ElementsHttpsModel] = []
        for model in networkModels {
            if shouldIncludeModel(model: model, searchTerm: searchTerm) {
                result.append(model)
            }
        }

        let statisticsItems = generateStatisticsItems(models: result)
        presenter.presentDisplayData(titleItems: statisticsItems, networkModels: result, modelSelected: modelSelected)
    }

    private func shouldIncludeModel(model: ElementsHttpsModel, searchTerm: String) -> Bool {
        guard let paths = model.requestModel.requestURL?.pathComponents, let host = model.requestModel.requestURL?.host?.lowercased() else { return false }
        for component in paths {
            if component.lowercased().hasPrefix(searchTerm.lowercased()) {
                return true
            }
        }
        for component in host.components(separatedBy: "/") {
            if component.hasPrefix(searchTerm.lowercased()) {
                return true
            }
        }
        return false
    }
}

extension NetworkMonitorInteractor {

    func loadData() {
        let networkModels = obtainValidRequestModels()
        let statisticsItems = generateStatisticsItems(models: networkModels)
        presenter.presentDisplayData(titleItems: statisticsItems, networkModels: networkModels, modelSelected: modelSelected)
    }

    private func obtainValidRequestModels() -> [ElementsHttpsModel] {
        var selectedHosts: Set<String>?
        let hostFilter = currentFilters?.first(where: { container in
            container.section.displayID == NetworkMonitorHostFilterSection.hostURL.rawValue
        })
        if let hostFilter = hostFilter {
            selectedHosts = hostFilter.selectedItems.isEmpty ? nil : hostFilter.selectedItems
        }
        var selectedMethods: Set<String>?
        let methodFilter = currentFilters?.first(where: { container in
            container.section.displayID == NetworkMonitorMethodFilterSection.methods.rawValue
        })
        if let methodFilter = methodFilter {
            selectedMethods =  methodFilter.selectedItems.isEmpty ? nil : methodFilter.selectedItems
        }
        return NetworkMonitor.shared.getAllModels(
            sortOption: sortOption,
            order: sortOrder,
            selectedHosts: selectedHosts,
            selectedMethods: selectedMethods
        )
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRequestStateChanged), name: NetworkMonitorNotifications.newRequestAdded.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRequestStateChanged), name: NetworkMonitorNotifications.requestCompleted.name, object: nil)
    }

    private func generateStatisticsItems(models: [ElementsHttpsModel]) -> [NetworkStatisticsItem] {
        var items: [NetworkStatisticsItem] = []
        items.append(NetworkStatisticsItem(
            displayTitle: "Network\nRequests",
            value: String(models.count)
        ))
        items.append(NetworkStatisticsItem(
            displayTitle: "Average\nTime",
            value: getAverageResponseTime(models: models).networkMSDisplay
        ))
        items.append(NetworkStatisticsItem(
            displayTitle: "Failed\nRequests",
            value: String(getFailedResponseCount(models: models))
        ))
        items.append(NetworkStatisticsItem(
            displayTitle: "Total\nUpload",
            value: calcTotalUploadSize(models: models)
        ))
        items.append(NetworkStatisticsItem(
            displayTitle: "Total\nDownload",
            value: calcTotalDownloadSize(models: models)
        ))
        return items
    }

    private func modelSelected(id: String) {
        let model = NetworkMonitor.shared.getAllModels().filter { $0.identifier == id }.first
        guard let nonNilModel = model else {
            return
        }
        presenter.presentRequestDetail(model: nonNilModel)
    }

    private func getAverageResponseTime(models: [ElementsHttpsModel]) -> Float {
        var totalTime: Float = 0
        var validModelCount: Float = 0
        for model in models {
            guard let timeInterval = model.timeInterval else { continue }
            totalTime += timeInterval
            validModelCount += 1
        }
        return totalTime / validModelCount
    }

    private func getFailedResponseCount(models: [ElementsHttpsModel]) -> Int {
        return models.reduce(0, { (result, model) in
            let count = (model.responseModel.responseStatus == .failed || model.responseModel.responseStatus == .timeout) ? 1 : 0
            return result + count
        })
    }

    private func getNumberOfGetRequests(models: [ElementsHttpsModel]) -> Int {
        return models.reduce(0) { (result, model) in
            guard let method = model.requestModel.method else { return result }
            return result + (method == .get ? 1 : 0)
        }
    }

    private func getNumberOfPostRequests(models: [ElementsHttpsModel]) -> Int {
        return models.reduce(0) { (result, model) in
            guard let method = model.requestModel.method else { return result }
            return result + (method == .post ? 1 : 0)
        }
    }

    private func calcTotalUploadSize(models: [ElementsHttpsModel]) -> String {
        let size = models.reduce(0) { (result, model) in
            return Int64(result) + (model.requestModel.requestBodyLength ?? 0)
        }
        return size.dataDisplayText
    }

    private func calcTotalDownloadSize(models: [ElementsHttpsModel]) -> String {
        let size = models.reduce(0) { (result, model) in
            return Int64(result) + (model.responseModel.responseBodyLength ?? 0)
        }
        return size.dataDisplayText
    }
}

extension NetworkMonitorInteractor {

    private func generateSortOptionsAlertController() -> UIAlertController {
        let actionSheet = UIAlertController()
        actionSheet.addAction(UIAlertAction(title: constants.sortByStartTime, style: .default, handler: { [weak self] _ in
            self?.sortDataByStartTime()
        }))

        actionSheet.addAction(UIAlertAction(title: constants.sortByResponseTime, style: .default, handler: { [weak self] _ in
            self?.sortDataByResponseTime()
        }))

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("cancel_action", comment: ""), style: .cancel, handler: nil))
        return actionSheet
    }

    private func sortDataByStartTime() {
        if sortOption == .startTime {
            // tapped again on the same option, change order
            sortOrder = sortOrder.reversed()
        } else {
            sortOption = .startTime
        }
        loadData()
    }

    private func sortDataByResponseTime() {
        if sortOption == .responseTime {
            // tapped again on the same option, change order
            sortOrder = sortOrder.reversed()
        } else {
            sortOption = .responseTime
        }
        loadData()
    }
}

extension NetworkMonitorInteractor {

    @objc
    private func handleRequestStateChanged() {
        DispatchQueue.main.async { [weak self] in
            self?.loadData()
        }
    }
}
