//
//  SettingsCoordinator.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/15/19.
//

import UIKit

protocol SettingsCoordinatorDelegate: class {
    func didDismiss(in coordinator: Coordinator)
    func applySettings(_ settings: [ElementsFilterContainer])
}

final class SettingsCoordinator: NSObject, Coordinator {

    let router: Router
    var coordinators: [Coordinator] = []
    let rootViewController: SettingsViewController

    weak var delegate: SettingsCoordinatorDelegate?

    init(router: Router, currentSettings: [ElementsFilterContainer]?) {
        self.router = router
        self.router.setNavigationBarStyle(style: .dark)
        let presenter = SettingsPresenter()
        let interactor = SettingsInteractor(presenter: presenter, currentSettings: currentSettings)
        rootViewController = SettingsViewController(interactor: interactor)
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

extension SettingsCoordinator: Themeable {

    func apply(theme: ElementsTheme) {
        router.setNavigationBarStyle(style: theme.type == .dark ? .dark : .white)
        router.navigationController.navigationBar.layoutIfNeeded()
    }
}

extension SettingsCoordinator: SettingsViewControllerDelegate {

    func dismiss() {
        router.dismissModule()
        delegate?.didDismiss(in: self)
    }

    func applySettings() {
        self.delegate?.applySettings(self.rootViewController.getCurrentSettings())
        self.dismiss()
    }
}

extension SettingsCoordinator: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.didDismiss(in: self)
    }
}
