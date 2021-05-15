//
//  TextPadPresenter.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

protocol TextPadPresenterOutput: class {
    func showAlertController(alert: UIViewController)
    func showPresentationData(displayText: NSAttributedString)
    func showDisplayText(displayText: String)
    func showFirstSearchOccurance(range: NSRange)
    func showNextMatch(term: String)
    func showPrevMatch(term: String)
    func showRewriteToggleView(animated: Bool)
    func hideRewriteToggleView(animated: Bool)
}

protocol TextPadPresenterType: class {
    func presentAlertController(alert: UIViewController)
    func presentDisplayData(displayText: NSAttributedString)
    func presentDisplayText(displayText: String)
    func presentFirstSearchOccurance(range: NSRange)
    func presentNextMatch(term: String)
    func presentPrevMatch(term: String)
    func presentRewriteToggleView(animated: Bool)
    func dismissRewriteToggleView(animated: Bool)
}

public final class TextPadPresenter: TextPadPresenterType {

    weak var output: TextPadPresenterOutput?

    func presentDisplayData(displayText: NSAttributedString) {
        output?.showPresentationData(displayText: displayText)
    }

    func presentFirstSearchOccurance(range: NSRange) {
        output?.showFirstSearchOccurance(range: range)
    }

    func presentDisplayText(displayText: String) {
        output?.showDisplayText(displayText: displayText)
    }

    func presentNextMatch(term: String) {
        output?.showNextMatch(term: term)
    }

    func presentPrevMatch(term: String) {
        output?.showPrevMatch(term: term)
    }

    func presentAlertController(alert: UIViewController) {
        output?.showAlertController(alert: alert)
    }

    func presentRewriteToggleView(animated: Bool) {
        output?.showRewriteToggleView(animated: animated)
    }

    func dismissRewriteToggleView(animated: Bool) {
        output?.hideRewriteToggleView(animated: animated)
    }
}
