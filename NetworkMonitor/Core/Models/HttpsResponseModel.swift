//
//  ElementsHttpsResponseModel.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 12/12/19.
//

import UIKit

public enum ElementsHttpsResponseStatus {
    case succeeded
    case loading
    case timeout
    case failed
}

open class ElementsHttpsResponseModel: NSObject, NSCopying {

    public var response: URLResponse?
    public var status: Int?
    public var contentType: String?
    public var responseDate: Date?
    public var responseTime: String?
    public var headers: [AnyHashable: Any]?
    public var responseBodyLength: Int64?
    public var shortType: HTTPModelShortType = .other

    public var responseStatus: ElementsHttpsResponseStatus = .loading

    public var statusDisplay: String {
        if let status = status {
            return String(status)
        }
        if responseStatus == .timeout {
            return String.timeoutText
        }
        return String.loadingText
    }

    func save(response: URLResponse) {
        self.response = response
        responseDate = Date()
        responseTime = DateFormatter.timeFormatter.string(from: Date())
        status = response.getStatus()
        headers = response.getHeaders()
        responseStatus = isSuccessStatus(code: status) ? .succeeded : .failed
        if let contentType = headers?["Content-Type"] as? String {
            self.contentType = contentType.components(separatedBy: ";").first
            shortType = HTTPModelShortType.getShortTypeFrom(contentType) ?? .other
        }
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = ElementsHttpsResponseModel()
        copy.response = response
        copy.responseDate = responseDate
        copy.responseTime =  responseTime
        copy.status = status
        copy.headers = headers
        copy.status = status
        copy.contentType = contentType
        copy.shortType = shortType
        return copy
    }

    public func isSuccessStatus(code: Int?) -> Bool {
        guard let code = code else {
            return false
        }
        return code < 400
    }

    public func isSuccessful() -> Bool {
        return isSuccessStatus(code: status)
    }
}
