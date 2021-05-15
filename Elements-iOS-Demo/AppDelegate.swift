//
//  AppDelegate.swift
//  Elements-iOS-Demo
//
//  Created by Tengqi Zhan on 2021-05-08.
//

import NetworkMonitor
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		NetworkMonitorEntry.shared.start()
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.backgroundColor = .white
		window?.rootViewController = ElementsDemoViewController()
		window?.makeKeyAndVisible()
		return true
	}
}
