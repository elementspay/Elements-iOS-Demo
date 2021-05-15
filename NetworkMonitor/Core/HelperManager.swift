//
//  HelperManager.swift
//  AMPopTip
//
//  Created by Marvin Zhan on 8/18/19.
//

import UIKit

final class HelperManager {

    static func textHeight(_ text: String?, width: CGFloat, font: UIFont) -> CGFloat {
        guard let text = text else {
            return 0
        }
        let constrainedSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [NSAttributedString.Key.font: font]
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (text as NSString).boundingRect(with: constrainedSize, options: options, attributes: attributes, context: nil)
        return ceil(bounds.height)
    }

    static func textWidth(_ text: String?, font: UIFont) -> CGFloat {
        guard let text = text else {
            return 0
        }
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = text.size(withAttributes: fontAttributes)
        return size.width
    }

    static func stubbedResponse(_ filename: String) -> Data {
        @objc class TestClass: NSObject { }

        let bundle = Bundle.main
        guard let path = bundle.path(forResource: filename, ofType: "json") else {
            return Data()
        }

        return (try? Data(contentsOf: URL(fileURLWithPath: path))) ?? Data()
    }
}
