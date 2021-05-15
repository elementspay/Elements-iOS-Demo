//
//  NetworkMonitorViewController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/11/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit
import IGListKit

protocol NetworkMonitorViewControllerDelegate: class {
    func dismiss()
    func routeToSettingsPage(currentSettings: [ElementsFilterContainer]?)
    func routeToRequestDetail(model: ElementsHttpsModel)
    func routeToHostPicker(currentFilters: [ElementsFilterContainer]?)
}

open class NetworkMonitorViewController: BaseViewController {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    private let interactor: NetworkMonitorInteractor
    private let headerView: NetworkMonitorHeaderView
    private let actionBar: NetworkMonitorActionBarView
    private let collectionView: UICollectionView
    private let refreshControl: UIRefreshControl
    private var sectionData: [ListDiffable] = []
    private var firstLoad: Bool = true

    weak var delegate: NetworkMonitorViewControllerDelegate?

    public init(interactor: NetworkMonitorInteractor) {
        self.interactor = interactor
        self.refreshControl = UIRefreshControl()
        self.headerView = NetworkMonitorHeaderView()
        self.actionBar = NetworkMonitorActionBarView()
        self.collectionView = UICollectionView(
            frame: .zero, collectionViewLayout: ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false)
        )
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

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var padding: CGFloat = 0
        if #available(iOS 11.0, *) {
            padding = self.view.safeAreaInsets.bottom
        }
        actionBar.snp.updateConstraints { make in
            make.height.equalTo(NetworkMonitorActionBarView.Constants().height + padding)
        }
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        if firstLoad {
            firstLoad = false
            self.view.backgroundColor = theme.colors.backgroundColor
            self.collectionView.backgroundColor = theme.colors.backgroundColor
            self.refreshControl.tintColor = theme.colors.primaryTextColorLightCanvas
        } else {
            UIView.animate(withDuration: theme.themeChangeAnimDuration, delay: 0, options: [.curveEaseInOut], animations: {
                self.view.backgroundColor = theme.colors.backgroundColor
                self.collectionView.backgroundColor = theme.colors.backgroundColor
                self.refreshControl.tintColor = theme.colors.primaryTextColorLightCanvas
            })
        }
        self.setupNavigationItem(theme: theme)
    }

    override open func adjustViewWhenKeyboardShow(notification: NSNotification) {
        guard let keyboard = obtainKeyboardInfo(from: notification) else { return }
        var insets = collectionView.contentInset
        insets.bottom += keyboard.keyboardHeight
        collectionView.contentInset = insets
    }

    override open func adjustViewWhenKeyboardDismiss(notification: NSNotification) {
        collectionView.contentInset = .zero
    }

    func applyHostFilters(filters: [ElementsFilterContainer]) {
        interactor.applyFilters(filters: filters)
    }

    func applySettings(settings: [ElementsFilterContainer]) {
        interactor.applySettings(settings: settings)
    }

    private func loadData() {
        interactor.loadData()
    }
}

extension NetworkMonitorViewController {

    private func setupUI() {
        setupCollectionView()
        setupRefreshControl()
        setupHeaderView()
        setupActionBar()
        setupConstraints()
    }

    private func setupNavigationItem(theme: ElementsTheme) {
        navigationItem.title = "Network Requests"
        let leftBarButton = UIBarButtonItem(image: theme.images.closeIcon.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismissButtonTapped))
        navigationItem.setLeftBarButtonItems([leftBarButton], animated: false)

        let rightBarButton = UIBarButtonItem(image: theme.images.settingsIcon, style: .plain, target: self, action: #selector(settingsButtonTapped))
        navigationItem.setRightBarButtonItems([rightBarButton], animated: false)
    }

    private func setupActionBar() {
        view.addSubview(actionBar)
        actionBar.sortAction = sortAction
        actionBar.selectHostAction = selectHostAction
        actionBar.clearAction = clearAction
    }

    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    private func setupHeaderView() {
        view.addSubview(headerView)
        headerView.delegate = self
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.showsVerticalScrollIndicator = true
        collectionView.alwaysBounceHorizontal = false
    }

    private func setupConstraints() {
        headerView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(NetworkMonitorHeaderView.Constants().caclHeight())
        }

        collectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalTo(actionBar.snp.top)
        }

        actionBar.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(NetworkMonitorActionBarView.Constants().height)
        }
    }
}

extension NetworkMonitorViewController: ListAdapterDataSource {

    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return sectionData
    }

    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is NetworkStatisticsItemsModel:
            return NetworkStatisticsSectionController()
        case is NetworkRequestsModel:
            return NetworkRequestsSectionController()
        case is NetworkStatisticsItemModel:
            return NetworkStatisticsItemSectionController()
        case is NetworkRequestDisplayModel:
            return NetworkRequestSectionController()
        default:
            fatalError()
        }
    }

    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension NetworkMonitorViewController: NetworkMonitorPresenterOutput {

    func showPresentationData(models: [ListDiffable]) {
        sectionData = models
        adapter.performUpdates(animated: true)
        refreshControl.endRefreshing()
    }

    func showRequestDetail(model: ElementsHttpsModel) {
        delegate?.routeToRequestDetail(model: model)
    }

    func showAlertController(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }

    func showHostFilterModule(currentFilters: [ElementsFilterContainer]?) {
        delegate?.routeToHostPicker(currentFilters: currentFilters)
    }

    func showSettingsModule(currentSettings: [ElementsFilterContainer]?) {
        delegate?.routeToSettingsPage(currentSettings: currentSettings)
    }
}

extension NetworkMonitorViewController: NetworkMonitorHeaderViewDelegate {

    func autoCompleteRequests(searchTerm: String) {
        interactor.autoCompleteRequests(searchTerm: searchTerm)
    }
}

extension NetworkMonitorViewController {

    private func sortAction() {
        interactor.handleSortButtonTapped()
    }

    private func selectHostAction() {
        interactor.handleHostFilter()
    }

    private func clearAction() {
        interactor.handleClearData()
    }
}

extension NetworkMonitorViewController {

    @objc
    private func dismissButtonTapped() {
        delegate?.dismiss()
    }

    @objc
    private func settingsButtonTapped() {
        interactor.handleSettingsAction()
    }

    @objc
    private func sortButtonTapped() {
        interactor.handleSortButtonTapped()
    }

    @objc
    private func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.loadData()
        }
    }
}
