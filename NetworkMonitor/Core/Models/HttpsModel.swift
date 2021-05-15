//
//  ElementsHttpsModel.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/11/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

open class ElementsHttpsModel: NSObject, NSCopying {

    struct Constants {
        let networkRequestBodyKey: String = "network_request_body_"
        let netowrkResponseBodyKey: String = "network_response_body_"
    }

    public var requestModel: ElementsHttpsRequestModel
    public var responseModel: ElementsHttpsResponseModel

    public var identifier: String = ""
    public var randomHash: String?
    public var noResponse: Bool = true
    public var timeInterval: Float?
    private let constants = Constants()

    public var responseTimeInterval: String {
        if let interval = timeInterval {
            return interval.networkMSDisplay
        }
        if responseModel.responseStatus == .timeout {
            return String.timeoutText
        }
        return String.loadingText
    }

    public override init() {
        requestModel = ElementsHttpsRequestModel()
        responseModel = ElementsHttpsResponseModel()
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = ElementsHttpsModel()
        copy.requestModel = (requestModel.copy() as? ElementsHttpsRequestModel) ?? requestModel
        copy.responseModel = (responseModel.copy() as? ElementsHttpsResponseModel) ?? responseModel
        copy.identifier =  identifier
        copy.noResponse = noResponse
        copy.timeInterval = timeInterval
        return copy
    }

    func applyRewriteCommand(_ command: AddRewriteRequestCommandType,
                             data: Data? = nil) {
        switch command {
        case .responseData:
            guard let response = responseModel.response,
                let data = data else {
                return
            }
            saveResponse(response, data: data)
        case .requestParamData:
            guard let request = requestModel.request,
                let data = data else {
                return
            }
            saveRequest(request, data: data)
        case .replaceQueryParamKey(let id, let newKey):
            requestModel.crudQueryItemKey(id, newKeyName: newKey)
        case .replaceQueryParamValue(let id, let newValue):
            requestModel.crudQueryItemValue(id, value: newValue)
        case .replaceHeaderKey(let id, let newKey):
            requestModel.crudHeaderItemKey(id, newKeyName: newKey)
        case .replaceHeaderValue(let id, let newValue):
            requestModel.crudHeaderItemValue(id, value: newValue)
        }
    }

    func applyRewriteCommand(_ command: RemoveRewriteRequestCommandType,
                             originModel: ElementsHttpsModel) {
        switch command {
        case .responseData:
            guard let response = responseModel.response,
                let data = originModel.getResponseBody().data(using: .utf8) else {
                return
            }
            saveResponse(response, data: data)
        case .requestParamData:
            guard let request = requestModel.request,
                let data = originModel.getRequestBody().data(using: .utf8) else {
                return
            }
            saveRequest(request, data: data)
        case .resetQueryParamKey(let id):
            requestModel.resetQueryItemKey(id: id)
        case .resetQueryParamValue(let id):
            requestModel.resetQueryItemValue(id: id)
        case .resetHeaderKey(let id):
            requestModel.resetHeaderItemKey(id: id)
        case .resetHeaderValue(let id):
            requestModel.resetHeaderItemValue(id: id)
        }
    }

    public func saveRequest(_ request: URLRequest, data: Data) {
        identifier = UUID().uuidString
        requestModel.save(request: request)
        saveRequestBodyData(data)
        logRequest()
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if self.responseModel.responseStatus == .loading {
                self.responseModel.responseStatus = .timeout
            }
        }
    }

    public func saveResponse(_ response: URLResponse, data: Data) {
        noResponse = false
        responseModel.save(response: response)
        NotificationCenter.default.post(
            name: NetworkMonitorNotifications.requestCompleted.name,
            object: nil
        )
        if let requestDate = requestModel.requestDate, let responseDate = responseModel.responseDate {
            timeInterval = Float(responseDate.timeIntervalSince(requestDate))
        }
        saveResponseBodyData(data)
        logResponse()
    }

    public func logRequest() {
        guard let filePath = NetworkStoragePath.sessionLog else { return }
        formattedRequestLogEntry().appendToFile(filePath: filePath)
    }

    public func logResponse() {
        guard let filePath = NetworkStoragePath.sessionLog else { return }
        formattedResponseLogEntry().appendToFile(filePath: filePath)
    }

    public func saveErrorResponse() {
        responseModel.responseDate = Date()
    }

    private func saveRequestBodyData(_ data: Data) {
        let bodyString = String(data: data, encoding: .utf8)
        requestModel.requestBodyLength = Int64(data.count)
        if let bodyString = bodyString, let filePath = getRequestBodyFilepath() {
            saveData(bodyString, toFile: filePath)
        }
    }

    private func saveResponseBodyData(_ data: Data) {
        var bodyString: String?
        if responseModel.shortType == .image {
            bodyString = data.base64EncodedString(options: .endLineWithLineFeed)
        } else {
            if let tempBodyString = String(data: data, encoding: .utf8) {
                bodyString = tempBodyString
            }
        }
        if let bodyString = bodyString, let filePath = getResponseBodyFilepath() {
            responseModel.responseBodyLength = Int64(data.count)
            saveData(bodyString, toFile: filePath)
        }
    }

    private func prettyOutput(_ rawData: Data, contentType: String? = nil) -> String {
        if let contentType = contentType {
            let shortType = HTTPModelShortType.getShortTypeFrom(contentType) ?? .other
            if let output = prettyPrint(rawData, type: shortType) {
                return output
            }
        }
        return String(data: rawData, encoding: .utf8) ?? ""
    }

    public func getRequestBody() -> String {
        guard let path = getRequestBodyFilepath(), let data = readRawData(path) else {
            return ""
        }
        return prettyOutput(data, contentType: requestModel.contentType)
    }

    public func getResponseBody() -> String {
        guard let path = getResponseBodyFilepath(), let data = readRawData(path) else {
            return ""
        }
        return prettyOutput(data, contentType: responseModel.contentType)
    }

    public func generateOrSetRandomHash() -> String {
        let newHash = UUID().uuidString
        if let hash = randomHash {
            return hash
        } else {
            randomHash = newHash
        }
        return newHash
    }

    public func getRequestBodyFilepath() -> String? {
        guard let dir = NetworkStoragePath.documents as NSString? else { return nil }
        let requestBodyFileName = constants.networkRequestBodyKey + "\(generateOrSetRandomHash())_request_body.txt"
        return dir.appendingPathComponent(requestBodyFileName)
    }

    public func getResponseBodyFilepath() -> String? {
        guard let dir = NetworkStoragePath.documents as NSString? else { return nil }
        let responseBodyFileName = constants.netowrkResponseBodyKey + "\(generateOrSetRandomHash())_response_body.txt"
        return dir.appendingPathComponent(responseBodyFileName)
    }

    public func saveData(_ dataString: String, toFile: String) {
        do {
            let url = URL(fileURLWithPath: toFile)
            try dataString.write(to: url, atomically: false, encoding: .utf8)
        } catch {
            print("Error when saving data. \(toFile)")
        }
    }

    public func readRawData(_ fromFile: String) -> Data? {
        return (try? Data(contentsOf: URL(fileURLWithPath: fromFile)))
    }

    public func prettyPrint(_ rawData: Data, type: HTTPModelShortType) -> String? {
        switch type {
        case .json:
            do {
                let rawJsonData = try JSONSerialization.jsonObject(with: rawData, options: [])
                let prettyPrintedString = try JSONSerialization.data(withJSONObject: rawJsonData, options: [.prettyPrinted])
                return String(data: prettyPrintedString, encoding: .utf8)
            } catch {
                return nil
            }
        case .urlEncoded:
            let dataString = String(data: rawData, encoding: .utf8)
            return dataString?.removingPercentEncoding
        default:
            return nil
        }
    }
}

extension ElementsHttpsModel {

    public func formattedRequestLogEntry() -> String {
        var log: String = ""
        if let requestURL = requestModel.requestURL {
            log.append("[Request URL - Start] - \(requestURL)\n")
        }
        if let requestMethod = requestModel.method {
            log.append("[Request Method] \(requestMethod)\n")
        }
        log.append("[Request Date] \(requestModel.requestDate ?? Date())\n")
        if let requestTime = requestModel.requestTime {
            log.append("[Request Time] \(requestTime)\n")
        }
        if let requestType = requestModel.contentType {
            log.append("[Request Type] \(requestType)\n")
        }
        if let requestTimeout = requestModel.timeout {
            log.append("[Request Timeout] \(requestTimeout)\n")
        }
        if !requestModel.headers.isEmpty {
            log.append("[Request Headers]\n\(requestModel.headers)\n")
        }
        log.append("[Request Body]\n \(getRequestBody())\n")
        if let requestURL = requestModel.requestURL {
            log.append("[End Request] - \(requestURL)\n\n")
        }
        return log
    }

    public func formattedResponseLogEntry() -> String {
        var log: String = ""
        if let requestURL = requestModel.requestURL {
            log.append("[Start Response - \(requestURL)\n")
        }
        if let responseStatus = responseModel.status {
            log.append("[Response Status] \(responseStatus)\n")
        }
        if let responseType = responseModel.contentType {
            log.append("[Response Type] \(responseType)\n")
        }
        if let responseDate = responseModel.responseDate {
            log.append("[Response Date] \(responseDate)\n")
        }
        if let responseTime = responseModel.responseTime {
            log.append("[Response Time] \(responseTime)\n")
        }
        if let responseHeaders = responseModel.headers {
            log.append("[Response Headers]\n\(responseHeaders)\n\n")
        }
        log.append("[Response Body]\n \(getResponseBody())\n")
        if let requestURL = requestModel.requestURL {
            log.append("[End Response] - \(requestURL)\n\n")
        }
        return log
    }
}
