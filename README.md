# Elements-iOS-SDK Demo

[![Pod](https://img.shields.io/cocoapods/v/Elements.svg?style=flat)](http://cocoapods.org/pods/Elements)

The Elements iOS SDK makes it quick and easy to build an excellent payment experience in your iOS app. We provide powerful and customizable UI screens and elements that can be used out-of-the-box to collect your users' payment details. We also expose the low-level APIs that power those UIs so that you can build fully custom experiences.

Table of contents
=================

<!--ts-->
   * [Features](#features)
   * [Requirements](#requirements)
   * [Getting Started](#getting-started)
      * [Installation](#installation)
      * [Usage](#usage)
      * [Example](#example-app)
   * [Releases](#releases)
<!--te-->

## Features

**PCI Complaint**: We make it simple for you to collect sensitive data such as credit card numbers and remain [PCI compliant](https://stripe.com/docs/security#pci-dss-guidelines). This means the sensitive data is sent directly to Elements instead of passing through your server

**Elements API**: We provide [low-level APIs](https://stripe.dev/stripe-ios/docs/Classes/STPAPIClient.html) that correspond to objects and methods in the Elements API.

**Native UI**: (Coming soon in the future) We provide native screens and elements to collect payment details.

## Requirements

The Elements iOS SDK requires Xcode 11 or later and is compatible with apps targeting iOS 11 or above.

## Installation

Elements for iOS are available through CocoaPods.

### CocoaPods

Add `pod 'Elements'` to your Podfile.
Run `pod install`.

## Usage

### ElementsAPIClient

The `ElementsAPIClient` handles the low-level API communications to Elements server. i.e. Card Tokenization

### Initialize the API client

The API client requires clientToken fetched from your backend server. Once you have obtained your client key you can initialize the API client in the following way.

```swift
let apiClient: ElementsAPIClient = ElementsAPIClient(
    config: .init(
      // Configure your environment, eg. production vs sandbox
      environment: .production(clientToken: clientToken),
      // Optional if you want to take fall back to stripe 
      //if elements tokenization failed
      stripePublishableKey: stripeTestKey 
    )
)
```

In order to call the tokenize API, you need to create and pass in the `ElementsCardParams` object, for example:
```swift
let card = ElementsCardParams(
  cardNumber: "4242424242424242", 
  expiryMonth: 2, 
  expiryYear: 24, 
  securityCode: "242", 
  holderName: "Test"
)
```
Once you have created the `ElementsAPIClient` and `ElementsCardParams` you can call the following to tokenize a card.
```swift
apiClient.tokenizeCard(data: card) { result in
  switch result {
  case .success(let response):
   if let elementsToken = response.elementsToken {
     // Now you can pass this token object to your backend server
   }
   if let fallbackStripeToken = response.fallbackStripeToken {
     // If Elements tokenization failed, a stripe token will be generated if you have provided the `stripePublishableKey`
     // You can pass the stripe key to your backend server as a fall back.
   }
  case .failure(let error):
   if let apiError = error as? APIError {
     // Error contains the reason why tokenization failed.
   } else {
     // Generic Error object (i.e. network failed because of bad connection etc)
   }
 }
}
```

### ElementsToken

The ElementsToken struct returns the response received from Elements server once tokenization succeeded. It contains the corresponded elements token matching the `ElementsCardParams` you passed in the method. It will also contain an `ElementsCardResponse` object that has the tokenized card info.

```
▿ ElementsToken
  ▿ id : "tok_xxxxxxxxxxxxxxx
  ▿ card : ElementsCardResponse
    - id : "card-9a0bb04b-f5fb-4b3c-9129-15ae830ed585"
    ▿ last4 : Optional<String>
      - some : "4242"
    ▿ expiryMonth : Optional<UInt>
      - some : 2
    ▿ expiryYear : Optional<UInt>
      - some : 2042
    ▿ brand : Optional<String>
      - some : "VISA"
    ▿ fingerprint : Optional<String>
      - some : "w98Ef4AjZdgXlfBgzfYa4jnorJSFGHrH1ilsXw2xwl4="
```

### 3DS2 Flow

`ElementsAPIClient` also supports tokenize card with 3DS2 auth flow enabled. In order to handle 3DS2 flow correctly you need to pass a authContext param to the tokenization method.

```swift
private func tokenizeCard(card: ElementsCardParams) {
  apiClient.tokenizeCard(data: card, authContext: self) { [weak self] result in
    guard let self = self else { return }
    self.cardComponent?.stopLoadingIfNeeded()
    switch result {
    case .success(let response):
      if let elementsToken = response.elementsToken {
        print("Tokenization success! Check elements token object.")
      }
      if let fallbackStripeToken = response.fallbackStripeToken {
        print("Stripe tokenization success!")
      }
    case .failure(let error):
      if let apiError = error as? ElementsAPIError {
        print(apiError.errorMessage)
      } else {
        print(error.localizedDescription)
      }
    }
  }
}
```
To conform to the protocol you need to do the following:
```swift
extension YourViewController: ElementsAuthenticationContext {
  
  // Required, usually this gonna be your main controller hosting other view controllers.
  func elementsAuthHostController() -> UIViewController {
    return self
  }

  // Optional if you want to listen when the 3DS2 flow will begin.
  func authContextWillAppear() {
    print("3DS Auth controller appear...")
  }

  // Optional if you want to listen when the 3DS2 flow dismissed.
  func authContextWillDisappear() {
    print("3DS Auth controller disppear...")
  }
}
```

## Example App

Clone this repo and run `pod install` and then open `Elements-iOS-Demo.xcworkspace`. The demo app demonstrated how to use `ElementsAPIClient`.

## Releases

Release notices will get updated here.
