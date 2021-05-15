//
//  NetworkMonitorMainWindow.swift
//
//
//  Created by Marvin Zhan on 12/16/19.
//

import UIKit

protocol NetworkMonitorMainWindowDelegate: class {
    func shouldHandle(point: CGPoint) -> Bool
}

public final class NetworkMonitorMainWindow: UIWindow {

    weak var delegate: NetworkMonitorMainWindowDelegate?

    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return delegate?.shouldHandle(point: point) ?? false
    }
}
