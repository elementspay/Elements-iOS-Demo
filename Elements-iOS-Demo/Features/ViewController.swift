//
//  ViewController.swift
//  Elements-iOS-Demo
//
//  Created by Tengqi Zhan on 2021-05-08.
//

import Elements
import ElementsCard
import UIKit

final class ViewController: UIViewController {
	let clientKey = "eyJraWQiOiJlbnYiLCJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2MTk5MTI2OTcsIm1lcmNoYW50X2lkIjoiRzQ3R0RWWEhWSlRTRyIsImN1c3RvbWVyX2lkIjoiQTM1WVpVSFpVRVBWUCIsInNjb3BlIjoid3JpdGUiLCJleHBpcmVzX2luIjpudWxsfQ.juA-mnlk6nho7isT9KIeTGbZPEjS5C3OOl6_s_7nbfcppSmaXknaw5hoUvpP39Z4eYoITP4YPKPiPL5_idUGdQA5SLtBohSArkMJvoLci5vyGDvFkFBfivUGnyEPPJlQrtZlrjljjZTO7ZEATqqG5OPbYGTl1rkc-5M7JY0xo_OkEFcIPZ5IzF13mN3Ron-hA8bpOXixF_57m3XwfWcnyS9iYqyxTiJRivp5ltqwsAQDQNZj9VaPdSNRmas88HnKrRTjTDCxPpHytVsqPC9phdJ6DXvfgdtNi7Uy2UrRl4kE_1SKZX0rTDM2PaYYrb4f9MudeF2tZerjnIxxCgDcXg"

	let stripeKey = "pk_test_51HLcaZGIxBPZ7rpaxvAYG4JXt96FrFl5u1T7S4wQh6gKPmNmKsl3tCAARba2Jrce60qolY321XmZuDN3slduuU9900wmEXbYu0"

	private var currentViewController: UIViewController?
	private var cardComponent: CardComponent?

	private lazy var apiClient: ElementsAPIClient = {
		return ElementsAPIClient(config: .init(environment: .sandbox(clientKey: clientKey), stripePublishableKey: stripeKey))
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		presentCardComponent()
	}

	private func presentCardComponent() {
		let brands: [SupportedCardData] = [
			"mc", "visa", "amex", "maestro", "cup", "diners", "discover", "jcb"
		].map { SupportedCardData(brand: $0) }
		let config = CardComponent.Configuration(
			showsHolderNameField: true,
			showsStorePaymentMethodField: false,
			billingAddressMode: .none
		)
		cardComponent = CardComponent(
			paymentMethod: CardPaymentMethod(
				type: "scheme",
				name: "Elements Demo",
				fundingSource: nil,
				cardData: brands
			),
			configuration: config
		)
		cardComponent?.environment = .sandbox(clientKey: clientKey)
		cardComponent?.cardComponentDelegate = self
		cardComponent?.delegate = self

		guard let cardComponent = cardComponent else { return }
		replaceScreen(viewController: UINavigationController(rootViewController: cardComponent.viewController))
	}

	private func tokenizeCard(card: ElementsCardParams) {
		apiClient.tokenizeCard(data: card) { [weak self] result in
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
				if let apiError = error as? APIError {
					self.presentAlertView(title: "Error", message: apiError.errorMessage)
				} else {
					self.presentAlertView(title: "Error", message: error.localizedDescription)
				}
			}
		}
	}
}

extension ViewController {

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
		return token.pspTokens.reduce("", { $0 + "\($1.pspAccount.pspType.lowercased()): \($1.token)" })
	}
}

extension ViewController: CardComponentDelegate {
	func didChangeBIN(_ value: String, component: CardComponent) {
	}

	func didChangeCardBrand(_ value: [CardBrand]?, component: CardComponent) {
	}
}

extension ViewController: PaymentComponentDelegate {
	func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
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

	func didFail(with error: Error, from component: PaymentComponent) {
		print("Opps something went wrong \(error)")
	}
}
