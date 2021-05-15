//
//  ElementsTextField.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/15/19.
//

import UIKit

class ElementsTextField: UITextField {

    private let leftEdge: CGFloat

    var isCopyable: Bool = true {
        didSet {
            isUserInteractionEnabled = isCopyable
        }
    }

    init(leftEdge: CGFloat = 10) {
        self.leftEdge = leftEdge
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(showMenu(sender:))
        ))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }

    @objc
    func showMenu(sender: Any?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(copy(_:)))
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: leftEdge, bottom: 0, right: leftEdge))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: leftEdge, bottom: 0, right: leftEdge))
    }
}

//class InfoInputTextView: UITextView {
//
//    private let leftEdge: CGFloat
//
//    var isCopyable: Bool = true {
//        didSet {
//            isUserInteractionEnabled = isCopyable
//        }
//    }
//
//    init(leftEdge: CGFloat = 10) {
//        self.leftEdge = leftEdge
//        super.init(frame: CGRect.zero)
//        isUserInteractionEnabled = true
//        addGestureRecognizer(UILongPressGestureRecognizer(
//            target: self,
//            action: #selector(showMenu(sender:))
//        ))
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func copy(_ sender: Any?) {
//        UIPasteboard.general.string = text
//        UIMenuController.shared.setMenuVisible(false, animated: true)
//    }
//
//    @objc
//    func showMenu(sender: Any?) {
//        becomeFirstResponder()
//        let menu = UIMenuController.shared
//        if !menu.isMenuVisible {
//            menu.setTargetRect(bounds, in: self)
//            menu.setMenuVisible(true, animated: true)
//        }
//    }
//
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        return (action == #selector(copy(_:)))
//    }
//}
//
