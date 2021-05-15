//
//  NetworkRequestInfoViewController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import IGListKit
import UIKit

protocol NetworkRequestInfoViewControllerDelegate: class {
    func dismiss()
}

open class NetworkRequestInfoViewController: BaseListViewController {

    private let interactor: NetworkRequestInfoInteractor

    weak var delegate: NetworkRequestInfoViewControllerDelegate?

    init(interactor: NetworkRequestInfoInteractor) {
        self.interactor = interactor
        super.init()
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    required convenience public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeKeyboardNotifications()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        addKeyboardNotifications()
    }

    private func loadData() {
        interactor.loadData()
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        collectionView.backgroundColor = theme.colors.backgroundColor
    }

    override open func adjustViewWhenKeyboardShow(notification: NSNotification) {
        guard let info = obtainKeyboardInfo(from: notification) else { return }
        var bottomInset: CGFloat = info.keyboardHeight
        if #available(iOS 11.0, *) {
            bottomInset += view.safeAreaInsets.bottom
        }
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }

    override open func adjustViewWhenKeyboardDismiss(notification: NSNotification) {
        collectionView.contentInset = UIEdgeInsets.zero
    }
}

extension NetworkRequestInfoViewController {

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

extension NetworkRequestInfoViewController: ListAdapterDataSource {

    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return sectionData
    }

    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is NetworkRequestInfoPresentingModel:
            return NetworkRequestInfoSectionController()
        default:
            fatalError()
        }
    }

    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension NetworkRequestInfoViewController: NetworkRequestInfoPresenterOutput {

    func showPresentationData(models: [ListDiffable]) {
        sectionData = models
        adapter.performUpdates(animated: true)
    }
}

extension NetworkRequestInfoViewController {

    @objc
    private func dismissButtonTapped() {
        delegate?.dismiss()
    }
}
