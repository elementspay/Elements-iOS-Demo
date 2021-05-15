//
//  TextPadCoordinator.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

public protocol TextPadCoordinatorDelegate: class {
    func didDismiss(in coordinator: TextPadCoordinator)
}

public final class TextPadCoordinator: NSObject, Coordinator {

    let router: Router
    var coordinators: [Coordinator] = []
    let rootViewController: TextPadViewController

    weak public var delegate: TextPadCoordinatorDelegate?

    init(router: Router,
         model: ElementsHttpsModel,
         type: NetworkRequestDetailAdvanceDataType) {
        self.router = router
        let presenter = TextPadPresenter()
        let interactor = TextPadInteractor(presenter: presenter, model: model, type: type)
        rootViewController = TextPadViewController(interactor: interactor)
        presenter.output = rootViewController
    }

    public func start() {
        rootViewController.delegate = self
    }

    public func toPresentable() -> UIViewController {
        return rootViewController
    }
}

extension TextPadCoordinator: TextPadViewControllerDelegate {

    func dismiss() {
        router.popModule()
    }
}
