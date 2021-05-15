//
//  Coordinator.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 12/6/18.
//  Copyright © 2018 marvinzhan. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator: class, Presentable {
    var coordinators: [Coordinator] { get set }
    var router: Router { get }
}

extension Coordinator {

    func addCoordinator(_ coordinator: Coordinator) {
        coordinators.append(coordinator)
    }

    func removeCoordinator(_ coordinator: Coordinator?) {
        guard let coordinator = coordinator else {
            return
        }
        coordinators = coordinators.filter { $0 !== coordinator }
    }

    func removeAllCoordinators() {
        coordinators.removeAll()
    }

    func didDismiss(in coordinator: Coordinator) {
        removeCoordinator(coordinator)
    }
}
