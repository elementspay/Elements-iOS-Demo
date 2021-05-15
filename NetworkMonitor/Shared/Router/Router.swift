//
//  Router.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 12/6/18.
//  Copyright © 2018 marvinzhan. All rights reserved.
//

import UIKit

protocol Presentable {
    func toPresentable() -> UIViewController
}

extension UIViewController: Presentable {
    public func toPresentable() -> UIViewController {
        return self
    }
}

final class Router: NSObject {

    private var completions: [UIViewController : () -> Void]
    var rootViewController: UIViewController? {
        return navigationController.viewControllers.first
    }

    var hasRootController: Bool {
        return rootViewController != nil
    }

    let navigationController: ElementsNavigationControllerType

    init(navigationController: ElementsNavigationControllerType = ElementsNavigationController()) {
        self.navigationController = navigationController
        self.completions = [:]
        super.init()
        self.navigationController.delegate = self
    }

    func present(_ module: Presentable, animated: Bool = true, fullScreen: Bool = true) {
        if fullScreen {
            module.toPresentable().modalPresentationStyle = .overFullScreen
        } else if #available(iOS 13.0, *) {
            module.toPresentable().modalPresentationStyle = .automatic
        }
        navigationController.present(module.toPresentable(), animated: animated, completion: nil)
    }

    func dismissModule(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.dismiss(animated: animated, completion: completion)
    }

    func push(_ module: Presentable, animated: Bool = true, completion: (() -> Void)? = nil) {
        let controller = module.toPresentable()
        guard controller is UINavigationController == false else {
            return
        }
        if let completion = completion {
            completions[controller] = completion
        }
        navigationController.pushViewController(controller, animated: animated)
    }

    func popModule(animated: Bool = true) {
        if let controller = navigationController.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }

    func setNavigationBarStyle(style: NavigationBarStyle,
                               preferLargeTitles: Bool = true) {
        self.navigationController.navigationBarStyle = style
        if #available(iOS 11.0, *) {
            self.navigationController.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }

    func setRootModule(_ module: Presentable, hideBar: Bool = false) {
        // Call all completions so all coordinators can be deallocated
        completions.forEach { $0.value() }
        navigationController.setViewControllers([module.toPresentable()], animated: false)
        navigationController.isNavigationBarHidden = hideBar
    }

    func popToRootModule(animated: Bool) {
        if let controllers = navigationController.popToRootViewController(
            animated: animated) {
            controllers.forEach { runCompletion(for: $0) }
        }
    }

    private func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }

    func toPresentable() -> UIViewController {
        return navigationController
    }
}

extension Router: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(poppedViewController) else {
                return
        }
        runCompletion(for: poppedViewController)
    }
}
