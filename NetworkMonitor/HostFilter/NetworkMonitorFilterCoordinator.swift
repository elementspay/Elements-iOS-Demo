//
//  NetworkMonitorFilterCoordinator.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 9/11/19.
//

import UIKit

protocol NetworkMonitorFilterCoordinatorDelegate: class {
    func didDismiss(in coordinator: Coordinator)
    func applyFilters(_ filters: [ElementsFilterContainer])
}

final class NetworkMonitorFilterCoordinator: NSObject, Coordinator {

    let router: Router
    var coordinators: [Coordinator] = []
    let rootViewController: NetworkMonitorFilterViewController

    weak var delegate: NetworkMonitorFilterCoordinatorDelegate?

    init(router: Router, currentFilters: [ElementsFilterContainer]?) {
        self.router = router
        self.router.setNavigationBarStyle(style: .dark)
        let presenter = NetworkMonitorFilterPresenter()
        let interactor = NetworkMonitorFilterInteractor(presenter: presenter, currentFilters: currentFilters)
        rootViewController = NetworkMonitorFilterViewController(interactor: interactor)
        presenter.output = rootViewController
        super.init()
        ElementsTheme.manager.register(themeable: self)
    }

    func start() {
        rootViewController.delegate = self
        router.setRootModule(rootViewController, hideBar: false)
        router.navigationController.presentationController?.delegate = self
    }

    func toPresentable() -> UIViewController {
        return router.navigationController
    }
}

extension NetworkMonitorFilterCoordinator: Themeable {

    func apply(theme: ElementsTheme) {
        router.setNavigationBarStyle(style: theme.type == .dark ? .dark : .white)
        router.navigationController.navigationBar.layoutIfNeeded()
    }
}

extension NetworkMonitorFilterCoordinator: NetworkMonitorFilterViewControllerDelegate {

    func dismiss() {
        router.dismissModule()
        delegate?.didDismiss(in: self)
    }

    func applyFilters() {
        delegate?.applyFilters(rootViewController.getCurrentFilter())
        dismiss()
    }
}

extension NetworkMonitorFilterCoordinator: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.didDismiss(in: self)
    }
}
