//
//  SettingsViewController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/15/19.
//

import IGListKit
import UIKit

protocol SettingsViewControllerDelegate: class {
    func dismiss()
    func applySettings()
}

final class SettingsViewController: BaseSettingsViewController {

    private let interactor: SettingsInteractor
    weak var delegate: SettingsViewControllerDelegate?

    init(interactor: SettingsInteractor) {
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

    func getCurrentSettings() -> [ElementsFilterContainer] {
        return interactor.getCurrentSettings()
    }

    func resetFilter() {
        interactor.resetFilters()
    }

    override func applyFilterButtonTapped() {
        delegate?.applySettings()
    }

    override func dismissButtonTapped() {
        delegate?.dismiss()
    }

    override func setupUI() {
        setupNavigationBar()
        super.setupUI()
    }
}

extension SettingsViewController {

    private func setupNavigationBar() {
        navigationItem.title = "Settings"
        let leftBarButton = UIBarButtonItem(image: theme.images.closeIcon, style: .plain, target: self, action: #selector(dismissButtonTapped))
        navigationItem.setLeftBarButtonItems([leftBarButton], animated: false)
    }
}

extension SettingsViewController: SettingsPresenterOutput {

    func showPresentationData(models: [ListDiffable]) {
        sectionData = models
        adapter.performUpdates(animated: true)
    }
}

extension SettingsViewController: ListAdapterDataSource {

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
