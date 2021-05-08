//
//  ViewController.swift
//  Elements-iOS-Demo
//
//  Created by Tengqi Zhan on 2021-05-08.
//

import Elements
import UIKit

class ViewController: UIViewController {

	let clientKey = "eyJraWQiOiJlbnYiLCJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2MTk5MTI2OTcsIm1lcmNoYW50X2lkIjoiRzQ3R0RWWEhWSlRTRyIsImN1c3RvbWVyX2lkIjoiQTM1WVpVSFpVRVBWUCIsInNjb3BlIjoid3JpdGUiLCJleHBpcmVzX2luIjpudWxsfQ.juA-mnlk6nho7isT9KIeTGbZPEjS5C3OOl6_s_7nbfcppSmaXknaw5hoUvpP39Z4eYoITP4YPKPiPL5_idUGdQA5SLtBohSArkMJvoLci5vyGDvFkFBfivUGnyEPPJlQrtZlrjljjZTO7ZEATqqG5OPbYGTl1rkc-5M7JY0xo_OkEFcIPZ5IzF13mN3Ron-hA8bpOXixF_57m3XwfWcnyS9iYqyxTiJRivp5ltqwsAQDQNZj9VaPdSNRmas88HnKrRTjTDCxPpHytVsqPC9phdJ6DXvfgdtNi7Uy2UrRl4kE_1SKZX0rTDM2PaYYrb4f9MudeF2tZerjnIxxCgDcXg"

	let stripeKey = "pk_test_51HLcaZGIxBPZ7rpaxvAYG4JXt96FrFl5u1T7S4wQh6gKPmNmKsl3tCAARba2Jrce60qolY321XmZuDN3slduuU9900wmEXbYu0"

	private var apiClient: ElementsAPIClient?

	override func viewDidLoad() {
		super.viewDidLoad()

		tokenizeCard()
	}

	private func tokenizeCard() {
		let card = ElementsCardParams(cardNumber: "4242424242424242", expiryMonth: 2, expiryYear: 24, securityCode: "242", holderName: "Marvin")
		apiClient = ElementsAPIClient(config: .init(environment: .sandbox(clientKey: clientKey), stripePublishableKey: stripeKey))
		apiClient?.tokenizeCard(data: card) { result in
			switch result {
			case .success(let response):
				switch response {
				case .elements(let token):
					print("Tokenization success, elements token: \(token)")
				case .stripe(let token):
					print("Tokenization success, stripe token: \(token.id)")
				}
			case .failure(let error):
				print(error.localizedDescription)
			}
		}
	}
}

