//
//  NetworkMonitorFilterViewController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 9/11/19.
//

import IGListKit
import UIKit

protocol NetworkMonitorFilterViewControllerDelegate: class {
    func dismiss()
    func applyFilters()
}

final class NetworkMonitorFilterViewController: BaseSettingsViewController {

    private let interactor: NetworkMonitorFilterInteractor
    weak var delegate: NetworkMonitorFilterViewControllerDelegate?

    init(interactor: NetworkMonitorFilterInteractor) {
        self.interactor = interactor
        super.init()
        adapter.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }

    private func loadData() {
        interactor.loadPresentationData()
    }

    func getCurrentFilter() -> [ElementsFilterContainer] {
        return interactor.getCurrentFilters()
    }

    func resetFilter() {
        interactor.resetFilters()
    }

    override func applyFilterButtonTapped() {
        delegate?.applyFilters()
    }

    override func dismissButtonTapped() {
        delegate?.dismiss()
    }

    override func setupUI() {
        setupNavigationBar()
        super.setupUI()
    }
}

extension NetworkMonitorFilterViewController {

    private func setupNavigationBar() {
        navigationItem.title = "Filter"
        let leftBarButton = UIBarButtonItem(image: theme.images.closeIcon, style: .plain, target: self, action: #selector(dismissButtonTapped))
        navigationItem.setLeftBarButtonItems([leftBarButton], animated: false)
    }
}

extension NetworkMonitorFilterViewController: NetworkMonitorFilterPresenterOutput {

    func showPresentationData(models: [ListDiffable]) {
        sectionData = models
        adapter.performUpdates(animated: true)
    }
}

extension NetworkMonitorFilterViewController: ListAdapterDataSource {

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return sectionData
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is ElementsFilterModel:
            return FilterSectionController()
        default:
            fatalError()
        }
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
