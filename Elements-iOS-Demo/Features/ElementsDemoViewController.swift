//
//  ElementsDemoViewController.swift
//  Elements-iOS-Demo
//
//  Created by Tengqi Zhan on 2021-05-08.
//

import Elements
import NetworkMonitor
import UIKit

final class ElementsDemoViewController: UIViewController {

	private let clientToken = "eyJraWQiOiJlbnYiLCJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2Mjk0OTc0NjksIm1lcmNoYW50X2lkIjoiTUVSLU1BNXZqVGdMd1REQjVtWGdyeG45R2duYyIsImN1c3RvbWVyX2lkIjoiQ1VTLWVwTnd0bzRNUHNXeUhOOGJLZVlFelgzaiIsImV4dGVybmFsX2N1c3RvbWVyX2lkIjoiMTIzZTQ1NjctZTg5Yi0xMmQzLWE0NTYtNDI2NjE0MTc0MDAwIiwic2NvcGUiOiJyZWFkIHdyaXRlIn0.PXG07cHyC0f5IsaUZurZKNEV2Adhjw39kqANY-VEQMvuz250VAIbnBqOqH64Zq4Xiv_sadC5YCYekxDfiEOylMgQIAPPnFqPPeh4oAWUuBlC7Qh12M7zP1JXvqb7mG5kIB9Dovvq36NgpSwDlRlNJ7KS824z3dPA9meD5Ryw1mVUkFSjsW0AOgCJaT3TrzoXmCRd8sJslPAq1hmOWuRldjMURKd3r_RxwaL0Syv65bm6TR9z5Y0xvAvztENSG7CdQhiuyeKvBA0zU4X_LNV7zjC7jmM5it4aHwNl3CfN9s1Nu9vBqi5s3QlnJNALhI64_0EGV0TX_J8_wyecAIJdCw"
	private let stripeKey = "TODO: Optional if you want to provide your Stripe publishable key as a fall back method..."

	private var currentViewController: UIViewController?
	private var cardComponent: CardElement?
	private var monitorCoordinator: NetworkMonitorCoordinator?

	private lazy var apiClient: ElementsAPIClient = {
		return ElementsAPIClient(
			config: .init(
				environment: .sandbox(clientToken: clientToken),
				stripePublishableKey: stripeKey
			)
		)
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		presentCardComponent()
	}

	override public func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		showNetworkMonitor()
	}

	private func presentCardComponent() {
		let brands: [SupportedCardData] = [
			"visa", "master", "discover"
		].map { SupportedCardData(brand: $0) }
		let config = CardElement.Configuration(
			showsHolderNameField: true,
			showsStorePaymentMethodField: false, // TODO
			billingAddressMode: .none
		)
		cardComponent = CardElement(
			paymentMethod: CardPaymentMethod(
				type: "scheme",
				name: "Elements Demo",
				fundingSource: nil,
				cardData: brands
			),
			configuration: config
		)
    cardComponent?.environment = .portForward(clientToken: clientToken)
		cardComponent?.cardElementDelegate = self
		cardComponent?.delegate = self

		guard let cardComponent = cardComponent else { return }
		let navVC = UINavigationController(rootViewController: cardComponent.viewController)
		cardComponent.viewController.navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "network_monitor_image")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(rightNavBarButtonTapped)), animated: false)
		replaceScreen(viewController: navVC)
	}

	private func tokenizeCard(card: ElementsCardParams) {
		apiClient.tokenizeCard(data: card, authContext: self) { [weak self] result in
			guard let self = self else { return }
			self.cardComponent?.stopLoadingIfNeeded()
			switch result {
			case .success(let response):
				if let elementsToken = response.elementsToken {
					self.presentAlertView(title: "Tokenization success!", message: self.parseElementsTokenToDisplayString(token: elementsToken))
				}
				if let fallbackStripeToken = response.fallbackStripeToken {
					self.presentAlertView(title: "Stripe tokenization success!", message: "Stripe: \(fallbackStripeToken)")
				}
			case .failure(let error):
				if let apiError = error as? ElementsAPIError {
					self.presentAlertView(title: "Error", message: apiError.errorMessage)
				} else {
					self.presentAlertView(title: "Error", message: error.localizedDescription)
				}
			}
		}
	}
}

extension ElementsDemoViewController {

	private func presentAlertView(title: String, message: String, completion: (() -> Void)? = nil) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
			completion?()
		}))
		present(alert, animated: true, completion: nil)
	}

	private func replaceScreen(viewController: UIViewController) {
		viewController.willMove(toParent: self)
		addChild(viewController)
		view.addSubview(viewController.view)
		viewController.view.frame = view.frame
		currentViewController?.willMove(toParent: nil)
		currentViewController?.view.removeFromSuperview()
		currentViewController?.removeFromParent()
		viewController.didMove(toParent: self)
		currentViewController = viewController
	}

	private func parseElementsTokenToDisplayString(token: ElementsToken) -> String {
		var result = "Elements Token Object\n"
    result += "Token \n\(token.id)"
		result += "\nElements Card\n"
		var cardDisplay = "Card id: \(token.card?.id ?? "Unknown")\n"
		let brand = token.card?.brand ?? "Unknown brand"
		let last4 = token.card?.last4 ?? "Unknown last 4"
		cardDisplay += "Brand: \(brand)\nLast4: \(last4)"
		result += cardDisplay
		return result
	}
}

extension ElementsDemoViewController: CardElementDelegate {
  func didChangeBIN(_ value: String, element: CardElement) {
	}

  func didChangeCardBrand(_ value: [CardBrand]?, element: CardElement) {
	}
}

extension ElementsDemoViewController: ElementsAuthenticationContext {
  func elementsAuthHostController() -> UIViewController {
    return self
  }

  func authContextWillAppear() {
    print("3DS Auth controller appear...")
  }

  func authContextWillDisappear() {
    print("3DS Auth controller disppear...")
  }
}

extension ElementsDemoViewController: PaymentElementDelegate {
	func didSubmit(_ data: PaymentElementData, from component: PaymentElement) {
		guard let cardDetails = data.paymentMethod as? CardDetails else {
			print("Error: Failed getting card details from payment method.")
			return
		}
		guard let card = cardDetails.card else {
			print("Error: Card number is missing.")
			return
		}
		tokenizeCard(card: card)
	}

	func didFail(with error: Error, from component: PaymentElement) {
		print("Opps something went wrong \(error)")
	}
}

extension ElementsDemoViewController {

	private func showNetworkMonitor() {
		guard NetworkMonitor.shared.isEnabled() else { return }
		monitorCoordinator = NetworkMonitorCoordinator()
		monitorCoordinator?.delegate = self
		monitorCoordinator?.start()
		var topController: UIViewController? = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
		while topController?.presentedViewController != nil {
			topController = topController?.presentedViewController
		}
		topController?.present(monitorCoordinator!.toPresentable(), animated: true)
	}

	@objc
	private func rightNavBarButtonTapped() {
		showNetworkMonitor()
	}
}

extension ElementsDemoViewController: NetworkMonitorCoordinatorDelegate {
	func didDismiss(in coordinator: NetworkMonitorCoordinator) {
		monitorCoordinator = nil
	}
}
