//
//  RewriteRequest.swift
//
//
//  Created by Marvin Zhan on 12/13/19.
//

import UIKit

public enum AddRewriteRequestCommandType: Equatable {
    case responseData
    case requestParamData
    case replaceQueryParamKey(id: String, newKey: String)
    case replaceQueryParamValue(id: String, newValue: String)
    case replaceHeaderKey(id: String, newKey: String)
    case replaceHeaderValue(id: String, newValue: String)

    var rawRepresentaion: String {
        switch self {
        case .responseData:
            return "responseData"
        case .requestParamData:
            return "requestParamData"
        case .replaceQueryParamValue:
            return "replaceQueryParamValue"
        case .replaceQueryParamKey:
            return "replaceQueryParamKey"
        case .replaceHeaderKey:
            return "replaceHeaderKey"
        case .replaceHeaderValue:
            return "replaceHeaderValue"
        }
    }

    public static func == (lhs: AddRewriteRequestCommandType,
                           rhs: AddRewriteRequestCommandType) -> Bool {

        switch (lhs, rhs) {
        case (.responseData, .responseData):
            return true
        case (.requestParamData, .requestParamData):
            return true
        case (.replaceQueryParamKey(let lhsID, let lhsNewKey),
              .replaceQueryParamKey(let rhsID, let rhsNewKey)):
            return lhsID == rhsID && lhsNewKey == rhsNewKey
        case (.replaceQueryParamValue(let lhsID, let lhsValue),
              .replaceQueryParamValue(let rhsID, let rhsValue)):
            return lhsID == rhsID && lhsValue == rhsValue
        case (.replaceHeaderKey(let lhsID, let lhsNewKey),
              .replaceHeaderKey(let rhsID, let rhsNewKey)):
            return lhsID == rhsID && lhsNewKey == rhsNewKey
        case (.replaceHeaderValue(let lhsID, let lhsValue),
              .replaceHeaderValue(let rhsID, let rhsValue)):
            return lhsID == rhsID && lhsValue == rhsValue
        default:
            return false
        }
    }
}

public enum RemoveRewriteRequestCommandType {
    case responseData
    case requestParamData
    case resetQueryParamKey(id: String)
    case resetQueryParamValue(id: String)
    case resetHeaderKey(id: String)
    case resetHeaderValue(id: String)
}

func == (lhs: RemoveRewriteRequestCommandType, rhs: AddRewriteRequestCommandType) -> Bool {
    switch (lhs, rhs) {
    case (.responseData, .responseData):
        return true
    case (.requestParamData, .requestParamData):
        return true
    case (.resetQueryParamKey(let lhsID),
          .replaceQueryParamKey(let rhsID, _)):
        return lhsID == rhsID
    case (.resetQueryParamValue(let lhsID),
          .replaceQueryParamValue(let rhsID, _)):
        return lhsID == rhsID
    case (.resetHeaderKey(let lhsID),
          .replaceHeaderKey(let rhsID, _)):
        return lhsID == rhsID
    case (.resetQueryParamValue(let lhsID),
          .replaceHeaderValue(let rhsID, _)):
        return lhsID == rhsID
    default:
        return false
    }
}

public class ElementsRewriteRequest {

    public var originModel: ElementsHttpsModel
    public let latestResult: ElementsHttpsModel
    public var commands: [AddRewriteRequestCommandType]
    public var enabled: Bool

    public init(originModel: ElementsHttpsModel,
                commands: [AddRewriteRequestCommandType] = [],
                enabled: Bool = true) {
        self.originModel = originModel
        latestResult = (originModel.copy() as? ElementsHttpsModel) ?? ElementsHttpsModel()
        self.commands = commands
        self.enabled = enabled
    }

    func updateToLatestRequest(_ request: URLRequest, data: Data) {
        originModel.saveRequest(request, data: data)
        // keep the latest overrided value
        latestResult.saveRequest(request, data: latestResult.getRequestBody().data(using: .utf8) ?? Data())
        for command in commands {
            latestResult.applyRewriteCommand(command)
        }
    }

    func updateToLatestResponse(_ response: URLResponse, data: Data) {
        originModel.saveResponse(response, data: data)
        // keep the latest overrided value
        latestResult.saveResponse(response, data: latestResult.getResponseBody().data(using: .utf8) ?? Data())
    }
}
