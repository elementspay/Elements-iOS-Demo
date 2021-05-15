//
//  NetworkRequestDetailViewController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import IGListKit
import UIKit

protocol NetworkRequestDetailViewControllerDelegate: class {
    func dismiss()
    func routeToDetailData(model: ElementsHttpsModel, type: NetworkRequestDetailAdvanceDataType)
}

open class NetworkRequestDetailViewController: BaseListViewController {

    private let interactor: NetworkRequestDetailInteractor

    weak var delegate: NetworkRequestDetailViewControllerDelegate?

    init(interactor: NetworkRequestDetailInteractor) {
        self.interactor = interactor
        super.init()
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    required convenience public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }

    private func loadData() {
        interactor.loadData()
    }

    override func apply(theme: ElementsTheme) {
        let rightBarButton = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(exportButtonTapped))
        rightBarButton.setTitleTextAttributes([NSAttributedString.Key.font: theme.fonts.primaryTextFont], for: .normal)
        navigationItem.setRightBarButtonItems([rightBarButton], animated: false)
        collectionView.backgroundColor = theme.colors.backgroundColor
    }
}

extension NetworkRequestDetailViewController {

    private func setupUI() {
        navigationItem.title = "Request Details"
        setupCollectionView()
        setupConstraints()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.showsVerticalScrollIndicator = true
        collectionView.alwaysBounceHorizontal = false
    }

    private func setupConstraints() {
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension NetworkRequestDetailViewController: ListAdapterDataSource {

    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return sectionData
    }

    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is NetworkRequestDetailBasicInfoModel:
            return NetworkRequestDetailBasicInfoSectionController()
        case is NetworkRequestDetailAdvanceInfoModel:
            return NetworkRequestDetailAdvanceInfoSectionController()
        default:
            fatalError()
        }
    }

    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension NetworkRequestDetailViewController: NetworkRequestDetailPresenterOutput {

    func showPresentationData(models: [ListDiffable]) {
        sectionData = models
        adapter.performUpdates(animated: true)
    }

    func showDetailData(model: ElementsHttpsModel, type: NetworkRequestDetailAdvanceDataType) {
        delegate?.routeToDetailData(model: model, type: type)
    }

    func showAlertController(alert: UIViewController) {
        present(alert, animated: true, completion: nil)
    }
}

extension NetworkRequestDetailViewController {

    @objc
    private func dismissButtonTapped() {
        delegate?.dismiss()
    }

    @objc
    private func exportButtonTapped() {
        interactor.handleExportButtonTapped()
    }
}
