//
//  String+.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/15/19.
//

import UIKit

extension String {

    static let notApplicable = "N/A"
    static let loadingText = "Loading"
    static let timeoutText = "Timeout"

    static let requestedTimeHeader = "Requested-Time"

    static func percentage(originString: String?) -> String {
        guard let originString = originString, let percentageDouble = Double(originString) else {
            return "N/A"
        }
        return String(format: "%.1f%%", percentageDouble)
    }
}

extension String {

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}

extension String {
    func titleCase() -> String {
        return (self as NSString)
            .replacingOccurrences(of: "([A-Z])", with: " $1", options:
                .regularExpression, range: NSRange(location: 0, length: count))
            // optional
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized // If input is in llamaCase
    }
}

extension String {
    func nsRange(fromRange range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}
