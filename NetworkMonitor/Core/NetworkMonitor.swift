//
//  NetworkMonitor.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/11/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

public enum NetworkModelSortOption {
    case startTime
    case responseTime
}

open class NetworkMonitor {

    static public let shared: NetworkMonitor = NetworkMonitor()

    private var rewriteRequests: [ElementsRewriteRequest] = []
    private var models = [ElementsHttpsModel]()
    private let syncQueue = DispatchQueue(label: "NetowrkSyncQueue")

    private var started: Bool = false
    private var presented: Bool = false
    private var enabled: Bool = false

    private var ignoredURLs = [String]()
    private var filters = [Bool]()
    private var lastVisitDate: Date = Date()

    var cacheStoragePolicy = URLCache.StoragePolicy.notAllowed

    private init() {
    }

    open func start() {
        guard !self.started else { return }
        started = true
        URLProtocol.registerClass(NetworkProtocol.self)
        clearOldData()
        enabled = true
    }

    open func stop() {
        enabled = false
        URLProtocol.unregisterClass(NetworkProtocol.self)
        clearOldData()
        started = false
    }

    public func isEnabled() -> Bool {
        return enabled
    }

    open func setCachePolicy(_ policy: URLCache.StoragePolicy) {
        cacheStoragePolicy = policy
    }

    open func ignoreURL(_ url: String) {
        ignoredURLs.append(url)
    }

    func getLastVisitDate() -> Date {
        return lastVisitDate
    }

    func clearOldData() {
        clearModels()
        do {
            guard let documentsPath = NetworkStoragePath.documents,
                let sessionLog = NetworkStoragePath.sessionLog else {
                    return
            }
            let filePathsArray = try FileManager.default.subpathsOfDirectory(atPath: documentsPath)
            for filePath in filePathsArray {
                if filePath.hasPrefix("elements") {
                    try FileManager.default.removeItem(
                        atPath: (documentsPath as NSString).appendingPathComponent(filePath)
                    )
                }
            }
            try FileManager.default.removeItem(atPath: sessionLog)
        } catch {
            //print("Error when clear old data.")
        }
    }

    func getIgnoredURLs() -> [String] {
        return ignoredURLs
    }

    func cacheFilters(_ selectedFilters: [Bool]) {
        filters = selectedFilters
    }

    func getCachedFilters() -> [Bool] {
        if filters.isEmpty {
            filters = [Bool](repeating: true, count: HTTPModelShortType.allValues.count)
        }
        return self.filters
    }

    public func getPotentialRewriteRequest(urlRequest: URLRequest) -> ElementsRewriteRequest? {
        let rewriteRequest = rewriteRequests.first { (model) -> Bool in
            guard model.enabled else { return false }
            return model.originModel.requestModel.requestURL?.path == urlRequest.getPath() && model.originModel.requestModel.method?.rawValue == urlRequest.getHttpMethod() &&
                model.originModel.requestModel.requestURL?.host == urlRequest.getURL()?.host
        }
        return rewriteRequest
    }

    public func getPotentialRewriteRequest(originModel: ElementsHttpsModel,
                                           type: NetworkRequestDetailAdvanceDataType) -> ElementsRewriteRequest? {
        let rewriteRequest = rewriteRequests.first { (model) -> Bool in
            guard model.enabled else { return false }
            return model.originModel.requestModel == originModel.requestModel
        }
        for command in rewriteRequest?.commands ?? [] {
            if command == .responseData && type == .responseBody {
                return rewriteRequest
            }
            if command == .requestParamData && type == .requestBody {
                return rewriteRequest
            }
            if (command.rawRepresentaion == "replaceQueryParamValue"
                || command.rawRepresentaion == "replaceQueryParamKey"), type == .queryParams {
                return rewriteRequest
            }
            if (command.rawRepresentaion == "replaceHeaderValue"
                || command.rawRepresentaion == "replaceHeaderKey"), type == .requestHeader {
                return rewriteRequest
            }
        }
        return nil
    }
}

extension NetworkMonitor {

    public func add(model: ElementsHttpsModel) {
        syncQueue.async {
            guard !self.models.contains(where: { (localModel) -> Bool in
                return localModel.identifier == model.identifier
            }) else {
                return
            }
            NotificationCenter.default.post(
                name: NetworkMonitorNotifications.newRequestAdded.name,
                object: nil
            )
            self.models.insert(model, at: 0)
        }
    }

    public func addRewriteRequest(originModel: ElementsHttpsModel,
                                  data: Data? = nil,
                                  command: AddRewriteRequestCommandType,
                                  completion: (() -> Void)? = nil) {
        syncQueue.async {
            let modelCopy = (originModel.copy() as? ElementsHttpsModel) ?? ElementsHttpsModel()
            var rewriteRequestModel: ElementsRewriteRequest = ElementsRewriteRequest(originModel: modelCopy)
            var exsitingModel: Bool = false
            for rewriteRequest in self.rewriteRequests {
                if rewriteRequest.originModel.requestModel == originModel.requestModel {
                    rewriteRequestModel = rewriteRequest
                    exsitingModel = true
                }
            }
            if !exsitingModel {
                self.rewriteRequests.append(rewriteRequestModel)
            }
            rewriteRequestModel.latestResult.applyRewriteCommand(command, data: data)
            rewriteRequestModel.commands.append(command)
            completion?()
        }
    }

    public func removeRewriteRequest(originModel: ElementsHttpsModel,
                                     command: RemoveRewriteRequestCommandType) {
        for (i, rewriteRequest) in self.rewriteRequests.enumerated() {
            if rewriteRequest.originModel.requestModel == originModel.requestModel {
                rewriteRequest.latestResult.applyRewriteCommand(command, originModel: originModel)
                rewriteRequest.commands.removeAll { command == $0 }
                if rewriteRequest.commands.isEmpty {
                    rewriteRequests.remove(at: i)
                }
                return
            }
        }
    }

    public func isRequestBeingRewrote(model: ElementsHttpsModel) -> Bool {
        return !(rewriteRequests.filter { $0.originModel.requestModel == model.requestModel }.isEmpty)
    }

    public func clearModels(completion: (() -> Void)? = nil) {
        syncQueue.async {
            self.models.removeAll()
            completion?()
        }
    }

    public func clearRewriteRequestModels() {
        syncQueue.async {
            self.rewriteRequests.removeAll()
        }
    }

    public func getAllModels(sortOption: NetworkModelSortOption = .startTime,
                             order: ComparisonResult = .orderedAscending,
                             selectedHosts: Set<String>? = nil,
                             selectedMethods: Set<String>? = nil) -> [ElementsHttpsModel] {
        var result: [ElementsHttpsModel] = []
        switch sortOption {
        case .startTime:
            result = models.sorted(by: { (modelA, modelB) -> Bool in
                guard let requestADate = modelA.requestModel.requestDate, let requestBDate = modelB.requestModel.requestDate else {
                    return false
                }
                switch order {
                case .orderedAscending, .orderedSame:
                    return requestADate <= requestBDate
                case .orderedDescending:
                    return requestADate >= requestBDate
                }
            })
        case .responseTime:
            result = models.sorted(by: { (modelA, modelB) -> Bool in
                switch order {
                case .orderedAscending, .orderedSame:
                    return modelA.timeInterval ?? 0 <= modelB.timeInterval ?? 0
                case .orderedDescending:
                    return modelA.timeInterval ?? 0 >= modelB.timeInterval ?? 0
                }
            })
        }
        if let selectedHosts = selectedHosts {
            result = result.filter { model -> Bool in
                return selectedHosts.contains(model.requestModel.requestURL?.host ?? "")
            }
        }
        if let selectedMethods = selectedMethods {
            result = result.filter { model -> Bool in
                return selectedMethods.contains(model.requestModel.method?.rawValue ?? "")
            }
        }
        return result
    }
}
