//
//  NetworkMonitor.swift
//
//
//  Created by Marvin Zhan on 12/16/19.
//

import UIKit

public final class NetworkMonitorEntry {

    public static let shared: NetworkMonitorEntry = NetworkMonitorEntry()

    private let controller = MainEntryViewController()
    private let mainWindow = NetworkMonitorMainWindow(frame: UIScreen.main.bounds)

    private init() {
    }

    public func start(showFloatingPanel: Bool = false) {
        URLSessionConfiguration.connect()
        NetworkMonitor.shared.start()
        if showFloatingPanel {
            showEntryView()
        }
    }

    public func showEntryView() {
        mainWindow.delegate = controller
        mainWindow.rootViewController = controller
        mainWindow.windowLevel = .statusBar
        mainWindow.isHidden = false
    }

    public func hide() {
        mainWindow.isHidden = true
        mainWindow.removeFromSuperview()
    }
}
