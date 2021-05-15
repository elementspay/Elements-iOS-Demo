//
//  NetworkRequestDetailCooridnator.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

protocol NetworkRequestDetailCooridnatorDelegate: class {
    func didDismiss(in coordinator: Coordinator)
}

final class NetworkRequestDetailCooridnator: Coordinator {

    let router: Router
    var coordinators: [Coordinator] = []
    let rootViewController: NetworkRequestDetailViewController

    weak var delegate: NetworkRequestDetailCooridnatorDelegate?

    init(router: Router, model: ElementsHttpsModel) {
        self.router = router
        let presenter = NetworkRequestDetailPresenter()
        let interactor = NetworkRequestDetailInteractor(presenter: presenter, model: model)
        rootViewController = NetworkRequestDetailViewController(interactor: interactor)
        presenter.output = rootViewController
    }

    func start() {
        rootViewController.delegate = self
    }

    func toPresentable() -> UIViewController {
        return rootViewController
    }
}

extension NetworkRequestDetailCooridnator: NetworkRequestDetailViewControllerDelegate {

    func dismiss() {
        router.popModule()
    }

    func routeToDetailData(model: ElementsHttpsModel,
                           type: NetworkRequestDetailAdvanceDataType) {
        if type == .responseBody || type == .requestBody {
            routeToTextPad(model: model, type: type)
            return
        }
        let coordinator = NetworkRequestInfoCoordinator(router: router, model: model, type: type)
        addCoordinator(coordinator)
        coordinator.start()
        coordinator.delegate = self
        rootViewController.navigationItem.backBarButtonItem = UIBarButtonItem.empty
        router.push(coordinator, animated: true) {
            self.removeCoordinator(coordinator)
        }
    }

    private func routeToTextPad(model: ElementsHttpsModel,
                                    type: NetworkRequestDetailAdvanceDataType) {
        let coordinator = TextPadCoordinator(router: router, model: model, type: type)
        addCoordinator(coordinator)
        coordinator.start()
        coordinator.delegate = self
        rootViewController.navigationItem.backBarButtonItem = UIBarButtonItem.empty
        router.push(coordinator, animated: true) {
            self.removeCoordinator(coordinator)
        }
    }
}

extension NetworkRequestDetailCooridnator: NetworkRequestInfoCoordinatorDelegate, TextPadCoordinatorDelegate {

    func didDismiss(in coordinator: TextPadCoordinator) {
        removeCoordinator(coordinator)
    }
}
