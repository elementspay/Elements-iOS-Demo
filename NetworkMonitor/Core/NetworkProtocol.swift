//
//  NetworkProtocol.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/11/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

open class NetworkProtocol: URLProtocol {

    private struct Constrants {
        static let httpPrefix: String = "http"
        static let httpsPrefix: String = "https"
    }

    private static let networkProtocolInternalKey = "io.elements.networkProtocol"

    private lazy var session: URLSession = { [unowned self] in
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    private let model = ElementsHttpsModel()
    private var response: URLResponse?
    private var responseData: NSMutableData?
    private var originRequestBodyData: Data?

    private let constants = Constrants()

    override open class func canInit(with request: URLRequest) -> Bool {
        return canServeRequest(request)
    }

    override open class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = task.currentRequest else { return false }
        return canServeRequest(request)
    }

    private class func canServeRequest(_ request: URLRequest) -> Bool {
        guard NetworkMonitor.shared.isEnabled() else {
            return false
        }
        let key = NetworkProtocol.networkProtocolInternalKey
        guard URLProtocol.property(forKey: key, in: request) == nil,
            let url = request.url, url.absoluteString.hasPrefix(Constrants.httpPrefix)
                || url.absoluteString.hasPrefix(Constrants.httpsPrefix) else {
            return false
        }

        let absoluteString = url.absoluteString
        let isIgnoredURL = NetworkMonitor.shared.getIgnoredURLs().contains(
            where: { absoluteString.hasPrefix($0) }
        )
        return !isIgnoredURL
    }

    override open func startLoading() {
        // First of all, intercept the request being sent from client, updated origin model from rewrite request.
        originRequestBodyData = request.getBody()
        handleSaveRequest(originRequest: request)
        NetworkMonitor.shared.add(model: model)
        if let mutableRequest = (request as NSURLRequest).mutableCopy() as?
            NSMutableURLRequest {
            if let rewrite = NetworkMonitor.shared.getPotentialRewriteRequest(urlRequest: request) {
                // Apply the commands to the request that is going to be sent to the server.
                mutableRequest.url = rewrite.latestResult.requestModel.requestURL
                mutableRequest.httpBody = rewrite.latestResult.getRequestBody().data(using: .utf8)
                for header in rewrite.latestResult.requestModel.headers {
                    mutableRequest.setValue(header.name, forHTTPHeaderField: header.name)
                }
            }
            URLProtocol.setProperty(
                true, forKey: NetworkProtocol.networkProtocolInternalKey, in: mutableRequest
            )
            session.dataTask(with: mutableRequest as URLRequest).resume()
        }
    }

    override open func stopLoading() {
        session.getTasksWithCompletionHandler { dataTasks, _, _ in
            dataTasks.forEach { $0.cancel() }
        }
    }

    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
}

extension NetworkProtocol: URLSessionDataDelegate {

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseData?.append(data)
        if let request = NetworkMonitor.shared.getPotentialRewriteRequest(urlRequest: request) {
            if request.commands.contains(.responseData), let rewriteData = request.latestResult.getResponseBody().data(using: .utf8) {
                client?.urlProtocol(self, didLoad: rewriteData)
                return
            }
        }
        client?.urlProtocol(self, didLoad: data)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.response = response
        responseData = NSMutableData()
        client?.urlProtocol(
            self, didReceive: response, cacheStoragePolicy: NetworkMonitor.shared.cacheStoragePolicy
        )
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer {
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        }
        if error != nil {
            model.saveErrorResponse()
        } else if let response = response {
            handleSaveResponse(originResponse: response)
        }
    }

    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           willPerformHTTPRedirection response: HTTPURLResponse,
                           newRequest request: URLRequest,
                           completionHandler: @escaping (URLRequest?) -> Void) {
        let updatedRequest: URLRequest
        let key = NetworkProtocol.networkProtocolInternalKey
        if URLProtocol.property(forKey: key, in: request) != nil,
            let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest {
            URLProtocol.removeProperty(forKey: key, in: mutableRequest)
            updatedRequest = mutableRequest as URLRequest
        } else {
            updatedRequest = request
        }

        client?.urlProtocol(self, wasRedirectedTo: updatedRequest, redirectResponse: response)
        completionHandler(updatedRequest)
    }

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?
    ) -> Void) {
        let wrappedChallenge = URLAuthenticationChallenge(authenticationChallenge: challenge, sender: ElementsAuthenticationChallengeSender(handler: completionHandler))
        client?.urlProtocol(self, didReceive: wrappedChallenge)
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
}

extension NetworkProtocol {

    func handleSaveRequest(originRequest: URLRequest) {
        let originData = originRequestBodyData ?? Data()
        if let rewriteRequest = NetworkMonitor.shared.getPotentialRewriteRequest(urlRequest: request) {
            model.saveRequest(originRequest, data: originData)
            rewriteRequest.updateToLatestRequest(originRequest, data: originData)
        } else {
            model.saveRequest(originRequest, data: originData)
        }
    }

    func handleSaveResponse(originResponse: URLResponse) {
        let originData = (responseData ?? NSMutableData()) as Data
        if let rewriteRequest = NetworkMonitor.shared.getPotentialRewriteRequest(urlRequest: request) {
            model.saveResponse(originResponse, data: originData)
            rewriteRequest.updateToLatestResponse(originResponse, data: originData)
        } else {
            model.saveResponse(originResponse, data: originData)
        }
    }
}
