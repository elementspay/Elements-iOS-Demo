//
//  NetworkRequestInfoCoordinator.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

protocol NetworkRequestInfoCoordinatorDelegate: class {
    func didDismiss(in coordinator: Coordinator)
}

final class NetworkRequestInfoCoordinator: Coordinator {

    let router: Router
    var coordinators: [Coordinator] = []
    let rootViewController: NetworkRequestInfoViewController

    weak var delegate: NetworkRequestInfoCoordinatorDelegate?

    init(router: Router, model: ElementsHttpsModel, type: NetworkRequestDetailAdvanceDataType) {
        self.router = router
        let presenter = NetworkRequestInfoPresenter()
        let interactor = NetworkRequestInfoInteractor(presenter: presenter, model: model, type: type)
        rootViewController = NetworkRequestInfoViewController(interactor: interactor)
        presenter.output = rootViewController
    }

    func start() {
        rootViewController.delegate = self
    }

    func toPresentable() -> UIViewController {
        return rootViewController
    }
}

extension NetworkRequestInfoCoordinator: NetworkRequestInfoViewControllerDelegate {

    func dismiss() {
        router.popModule()
    }
}
