//
//  ActionsDemoViewController.swift
//  Elements-iOS-Demo
//
//  Created by Tengqi Zhan on 2021-05-19.
//

import IGListKit
import Elements
import UIKit

final class ActionsDemoViewController: UIViewController {
	private let clientToken = "TODO: Your client token fetched from backend goes here..."
	private var driver: ElementsActionDriver?

	override func viewDidLoad() {
		super.viewDidLoad()
		startDriver()
	}

	private func startDriver() {
    driver = ElementsActionDriver(configuration: .init(environment: .production(clientToken: clientToken), returnURLScheme: "", style: nil), completionDelegate: self, presentingDelegate: self)
		driver?.requestKakaoPaySetup()
	}
}

extension ActionsDemoViewController: ElementsActionCompletionDelegate {
	func didFail(with error: Error, driver: ElementsActionDriver) {
		print(error.localizedDescription)
	}

	func didSuccess(with token: String?, driver: ElementsActionDriver) {
		print(token)
	}
}

extension ActionsDemoViewController: ElementsViewControllerPresentingDelegate {
	func requestToShow(viewController: UIViewController) {
		navigationController?.present(viewController, animated: true, completion: nil)
	}

	func requestToDismiss() {
		navigationController?.dismiss(animated: true, completion: nil)
	}
}
