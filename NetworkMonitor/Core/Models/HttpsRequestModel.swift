//
//  ElementsHttpsRequestModel.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 12/12/19.
//

import UIKit

public enum ElementsHttpsMethod: String, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

open class ElementsHttpsRequestModel: NSObject, NSCopying {

    public var request: URLRequest?
    public var requestURL: URL? {
        return request?.url
    }
    public var method: ElementsHttpsMethod? {
        return ElementsHttpsMethod(rawValue: request?.httpMethod ?? "")
    }
    public var cachePolicy: String? {
        return request?.getCachePolicy()
    }
    public var timeout: String? {
        return request?.getTimeout()
    }
    public var contentType: String? {
        return headers.filter { $0.name == "Content-Type" }.first?.value
    }

    public var queryItems: [ElementsURLItem] = []
    public var headers: [ElementsURLItem] = []

    public var requestDate: Date?
    public var requestTime: String?
    public var requestBodyLength: Int64?
    public var requestCurl: String?

    func save(request: URLRequest) {
        self.request = request
        if requestDate == nil {
            requestDate = Date()
        }
        requestTime = DateFormatter.timeFormatter.string(from: requestDate ?? Date())
        queryItems = replaceOverridedURLItem(oldItems: queryItems, newItems: request.getQueryItems())
        headers = replaceOverridedURLItem(oldItems: headers, newItems: request.getHeaders())
        requestCurl = request.getCurl()
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = ElementsHttpsRequestModel()
        copy.request = request
        copy.queryItems = queryItems.map { $0.copy() as! ElementsURLItem }
        copy.headers = headers.map { $0.copy() as! ElementsURLItem }
        copy.requestDate = requestDate
        copy.requestTime = requestTime
        copy.requestCurl = requestCurl
        return copy
    }

    func crudQueryItemValue(_ id: String, value: String?) {
        guard let requestURL = requestURL else { return }
        guard var urlComponents = URLComponents(string: requestURL.absoluteString) else {
            return
        }
        queryItems.filter { $0.id == id }.first?.value = value ?? ""
        urlComponents.queryItems = queryItems.map { $0.transformToURLQueryItem() }
        let url = URL(string: urlComponents.string ?? requestURL.absoluteString)
        self.request?.url = url
    }

    func crudQueryItemKey(_ id: String, newKeyName: String) {
        guard let requestURL = requestURL else { return }
        guard var urlComponents = URLComponents(string: requestURL.absoluteString) else {
            return
        }
        let item = queryItems.filter { $0.id == id }.first
        let originKeyName = item?.name
        // replace all items name with this new key name.
        queryItems.forEach { item in
            if item.name == originKeyName {
                item.name = newKeyName
            }
        }
        urlComponents.queryItems = queryItems.map { $0.transformToURLQueryItem() }
        let url = URL(string: urlComponents.string ?? requestURL.absoluteString)
        self.request?.url = url
    }

    func resetQueryItemValue(id: String) {
        queryItems.filter { $0.id == id }.first?.resetValue()
    }

    func resetQueryItemKey(id: String) {
        // reset all keys under same name with the one
        let currItem = queryItems.filter { $0.id == id }.first
        queryItems.forEach { item in
            if item.originName == currItem?.originName && item.name == currItem?.name {
                item.resetName()
            }
        }
    }

    func crudHeaderItemValue(_ id: String, value: String?) {
        let item = headers.filter { $0.id == id }.first
        item?.value = value ?? ""
        if let key = item?.name {
            request?.allHTTPHeaderFields?[key] = value
        }
    }

    func crudHeaderItemKey(_ id: String, newKeyName: String) {
        let item = headers.filter { $0.id == id }.first
        let originKeyName = item?.name
        // replace all items name with this new key name.
        headers.forEach { item in
            if item.name == originKeyName {
                item.name = newKeyName
            }
        }
        request?.allHTTPHeaderFields = Dictionary(uniqueKeysWithValues: headers.map { ($0.name, $0.value) })
    }

    func replaceOverridedURLItem(oldItems: [ElementsURLItem], newItems: [ElementsURLItem]) -> [ElementsURLItem] {
        var newLocalItems = newItems.mapToSet { $0 }
        for item in oldItems {
            guard item.isOverrided else { continue }
            let newItem = newLocalItems.filter { $0.name == item.originName }.first
            if let newItem = newItem {
                newLocalItems.remove(newItem)
                newLocalItems.insert(item)
            }
        }
        return Array(newLocalItems)
    }

    func resetHeaderItemValue(id: String) {
        headers.filter { $0.id == id }.first?.resetValue()
    }

    func resetHeaderItemKey(id: String) {
        // reset all keys under same name with the one
        let currItem = headers.filter { $0.id == id }.first
        headers.forEach { item in
            if item.originName == currItem?.originName && item.name == currItem?.name {
                item.resetName()
            }
        }
    }
}

public func == (lhs: ElementsHttpsRequestModel, rhs: ElementsHttpsRequestModel) -> Bool {
    return lhs.requestURL?.path == rhs.requestURL?.path && lhs.method == rhs.method && lhs.requestURL?.host == rhs.requestURL?.host
}
