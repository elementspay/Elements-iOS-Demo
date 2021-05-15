//
//  NetworkMonitorCoordinator.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/11/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

public protocol NetworkMonitorCoordinatorDelegate: class {
    func didDismiss(in coordinator: NetworkMonitorCoordinator)
}

public final class NetworkMonitorCoordinator: NSObject, Coordinator {

    let router: Router
    var coordinators: [Coordinator] = []
    let rootViewController: NetworkMonitorViewController

    weak public var delegate: NetworkMonitorCoordinatorDelegate?

    override public init() {
        self.router = Router()
        self.router.setNavigationBarStyle(style: .dark)
        self.router.navigationController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.router.navigationController.navigationBar.shadowImage = UIImage()
        let presenter = NetworkMonitorPresenter()
        let interactor = NetworkMonitorInteractor(presenter: presenter)
        rootViewController = NetworkMonitorViewController(interactor: interactor)
        presenter.output = rootViewController
        super.init()
        ElementsTheme.manager.register(themeable: self)
    }

    public func start() {
        rootViewController.delegate = self
        router.setRootModule(rootViewController)
        reset()
    }

    public func reset() {
        router.navigationController.presentationController?.delegate = self
    }

    public func toPresentable() -> UIViewController {
        return router.navigationController
    }
}

extension NetworkMonitorCoordinator: NetworkMonitorViewControllerDelegate {

    func dismiss() {
        router.dismissModule(animated: true) {
            self.delegate?.didDismiss(in: self)
        }
    }

    func routeToRequestDetail(model: ElementsHttpsModel) {
        let coordinator = NetworkRequestDetailCooridnator(router: router, model: model)
        addCoordinator(coordinator)
        coordinator.start()
        coordinator.delegate = self
        rootViewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        router.push(coordinator, animated: true) {
            self.removeCoordinator(coordinator)
        }
    }

    func routeToHostPicker(currentFilters: [ElementsFilterContainer]?) {
        let coordinator = NetworkMonitorFilterCoordinator(router: Router(), currentFilters: currentFilters)
        addCoordinator(coordinator)
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        router.present(coordinator, fullScreen: false)
    }

    func routeToSettingsPage(currentSettings: [ElementsFilterContainer]?) {
        let coordinator = SettingsCoordinator(router: Router(), currentSettings: currentSettings)
        addCoordinator(coordinator)
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        router.present(coordinator, fullScreen: false)
    }
}

extension NetworkMonitorCoordinator: NetworkMonitorFilterCoordinatorDelegate {

    func applyFilters(_ filters: [ElementsFilterContainer]) {
        rootViewController.applyHostFilters(filters: filters)
    }
}

extension NetworkMonitorCoordinator: SettingsCoordinatorDelegate {

    func applySettings(_ settings: [ElementsFilterContainer]) {
        rootViewController.applySettings(settings: settings)
    }
}

extension NetworkMonitorCoordinator: Themeable {

    func apply(theme: ElementsTheme) {
        UIView.animate(withDuration: theme.themeChangeAnimDuration, delay: 0, options: [.curveEaseInOut], animations: {
            self.router.setNavigationBarStyle(style: theme.type == .dark ? .dark : .white)
            self.router.navigationController.navigationBar.layoutIfNeeded()
        })
        router.navigationController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        router.navigationController.navigationBar.shadowImage = UIImage()
    }
}

extension NetworkMonitorCoordinator: NetworkRequestDetailCooridnatorDelegate {

    func didDismiss(in coordinator: Coordinator) {
        removeCoordinator(coordinator)
    }
}

extension NetworkMonitorCoordinator: UIAdaptivePresentationControllerDelegate {

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        coordinators.forEach {
            $0.coordinators.forEach { $0.router.popModule() }
            $0.removeAllCoordinators()
        }
        removeAllCoordinators()
        delegate?.didDismiss(in: self)
    }
}
