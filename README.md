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

## Getting Started

## Installation

Elements for iOS are available through [CocoaPods](http://cocoapods.org).

### CocoaPods

1. Add `pod 'Elements'` to your `Podfile`.
2. Run `pod install`.

## Usage

### ElementsAPIClient

The [ElementsAPIClient] handles the low level api communications to Elements server. i.e. Card Tokenization

#### Initialize the API client.

The api client requires `clientKey` fetched from your backend server. Once you have obtained your `clientKey` you can initialize the api client in the following way.

```swift
let apiClient: ElementsAPIClient = ElementsAPIClient(
    config: .init(
      environment: .sandbox(clientKey: clientKey),
      // Optional feild if you want to provide your psp customer info.
      pspCustomers: [
        PspCustomer(
          pspAccount: PspAccount(
            pspType: .stripe, 
            accountId: "Your stripe account id obtained from elements goes here"
          ), 
          // Customer id associated with the account, this is only applicable to Stripe
          customerId: "Your stripe customer Id, usually starts with cus_" 
        ),
        PspCustomer(
          pspAccount: PspAccount(
            pspType: .adyen, 
            accountId: "Your adyen account id obtained from elements goes here"
          ), 
          customerId: nil
        )
      ],
      // Optional if you want to take fall back to Stripe tokenization
      // if elements tokenization failed
      stripePublishableKey: stripeTestKey 
    )
)
```

In order to call the tokenize api, you need to create and pass in `ElementsCardParams` object, example:

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

The `ElementsToken` struct returns the response received from Elements server once tokenization succeeded. It contains the corresponded tokens matching the `[PspCustomer]` you have configured in `ElementsAPIClient`. It will also contains a `ElementsCardResponse` object that has the tokenized card info.

```swift
▿ ElementsToken
  ▿ pspTokens : 1 element
    ▿ 0 : PspToken
      ▿ pspAccount : PspAccount
        - pspType : "STRIPE"
        ▿ accountId : Optional<String>
          - some : "xxxxxxxxxxxxx"
      - customerId : nil
      - token : "tok_xxxxxxxxxxxxxxx"
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


### Example App

Clone this repo and run `pod install`. The demo app demonstrated how to use `ElementsAPIClient`.

## Releases

Release notices will get updated here.