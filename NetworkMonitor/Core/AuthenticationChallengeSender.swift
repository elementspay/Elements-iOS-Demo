//
//  ElementsAuthenticationChallengeSender.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/11/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

open class ElementsAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {

    typealias ElementsAuthenticationChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void

    let handler: ElementsAuthenticationChallengeHandler

    init(handler: @escaping ElementsAuthenticationChallengeHandler) {
        self.handler = handler
        super.init()
    }

    public func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        handler(.useCredential, credential)
    }

    public func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        handler(.useCredential, nil)
    }

    public func cancel(_ challenge: URLAuthenticationChallenge) {
        handler(.cancelAuthenticationChallenge, nil)
    }

    public func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
        handler(.performDefaultHandling, nil)
    }

    public func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
        handler(.rejectProtectionSpace, nil)
    }
}
