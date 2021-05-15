//
//  HTTPsShortType.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 12/12/19.
//

import UIKit

public enum HTTPModelShortType: String {

    case json = "JSON"
    case xml = "XML"
    case html = "HTML"
    case image = "Image"
    case other = "Other"
    case urlEncoded = "URLEncoded"

    static let allValues = [json, xml, html, image, other, .urlEncoded]

    static func getShortTypeFrom(_ contentType: String?) -> HTTPModelShortType? {
        guard let contentType = contentType else { return nil }
        if NSPredicate(format: "SELF MATCHES %@", "^application/(vnd\\.(.*)\\+)?json$").evaluate(with: contentType) {
            return .json
        }
        if contentType == "application/xml" || contentType == "text/xml" {
            return .xml
        }
        if contentType == "application/x-www-form-urlencoded" {
            return .urlEncoded
        }
        if contentType == "text/html" {
            return .html
        }
        if contentType.hasPrefix("image/") {
            return .image
        }
        return .other
    }
}
