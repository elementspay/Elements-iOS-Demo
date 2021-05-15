//
//  BaseViewController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/15/19.
//

import UIKit

public typealias KeyboardInfo = (
    option: UIView.AnimationOptions,
    keyboardHeight: CGFloat,
    duration: Double
)

public enum KeyboardState {
    case hide
    case show
}

public enum BaseViewControllerStyle {
    case withCustomNavBar
    case nativeNavBar
}

open class BaseViewController: UIViewController, Themeable {

    let theme = ApplicationDependency.manager.theme

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
            DispatchQueue.main.async {
                self.navigationController?.navigationBar.setNeedsLayout()
            }
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        ElementsTheme.manager.register(themeable: self)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required convenience public init?(coder aDecoder: NSCoder) {
        self.init()
    }

    func apply(theme: ElementsTheme) {
    }

    @objc
    open func adjustViewWhenKeyboardShow(notification: NSNotification) {
        // Children should override this method if using keyboard
    }

    @objc
    open func adjustViewWhenKeyboardDismiss(notification: NSNotification) {
        // Children should override this method if using keyboard
    }

    open func presentErrorAlertView(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            completion?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension BaseViewController {

    open func obtainKeyboardInfo(from notification: NSNotification) -> KeyboardInfo? {
        guard let userInfo = notification.userInfo else {
            return nil
        }

        guard let keyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
            let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as AnyObject).uint32Value else {
                return nil
        }

        let convertedFrame = self.view.convert(keyboardRect, from: nil)
        let heightOffset = self.view.bounds.size.height - convertedFrame.origin.y
        let options = UIView.AnimationOptions(rawValue: UInt(curve) << 16 | UIView.AnimationOptions.beginFromCurrentState.rawValue)
        // swiftlint:disable force_unwrapping
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        return (option: options,
                keyboardHeight: heightOffset,
                duration: duration ?? 0.25)
    }

    open func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustViewWhenKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustViewWhenKeyboardDismiss), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    open func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
