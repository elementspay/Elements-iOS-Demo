//
//  NetworkMonitorFilterInteractor.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 9/11/19.
//

import UIKit

enum NetworkMonitorHostFilterSection: String, ElementsFilterSection {
    case hostURL = "Host URL"

    var displayID: String { return rawValue }
    var toServerID: String { return rawValue }
}

enum NetworkMonitorMethodFilterSection: String, ElementsFilterSection {
    case methods = "Request Method"

    var displayID: String { return rawValue }
    var toServerID: String { return rawValue }
}

final class NetworkMonitorFilterInteractor {

    private let presenter: NetworkMonitorFilterPresenterType
    private var currentFilters: [ElementsFilterContainer]?

    init(presenter: NetworkMonitorFilterPresenterType,
         currentFilters: [ElementsFilterContainer]?) {
        self.presenter = presenter
        self.currentFilters = currentFilters
    }
}

extension NetworkMonitorFilterInteractor {

    func loadPresentationData() {
        if let currentFilters = currentFilters, !currentFilters.isEmpty {
            presenter.presentDisplayData(filters: currentFilters)
            return
        }
        let filters = configFliters()
        currentFilters = filters
        presenter.presentDisplayData(filters: filters)
    }

    func resetFilters() {
        let filters = configFliters()
        currentFilters = filters
        presenter.presentDisplayData(filters: filters)
    }

    func getCurrentFilters() -> [ElementsFilterContainer] {
        return currentFilters ?? []
    }

    private func configFliters() -> [ElementsFilterContainer] {
        return [generateMethodsFilters(), generateHostFilters()]
    }

    private func generateHostFilters() -> ElementsFilterContainer {
        var hostURLs: [String] = []
        for model in NetworkMonitor.shared.getAllModels() {
            guard let hostURL = model.requestModel.requestURL?.host else { continue }
            if !hostURLs.contains(hostURL) {
                hostURLs.append(hostURL)
            }
        }
        let options: [ElementsFilterSelection] = hostURLs.map {
            ($0, $0)
        }
        return ElementsFilterContainer(
            section: NetworkMonitorHostFilterSection.hostURL,
            selections: options,
            selectedItems: Set()
        )
    }

    private func generateMethodsFilters() -> ElementsFilterContainer {
        let options: [ElementsFilterSelection] = ElementsHttpsMethod.allCases.map { method in
            (method.rawValue, method.rawValue)
        }
        return ElementsFilterContainer(
            section: NetworkMonitorMethodFilterSection.methods,
            selections: options,
            selectedItems: Set()
        )
    }
}
