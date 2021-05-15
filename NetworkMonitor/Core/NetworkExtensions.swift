//
//  NetworkExtensions.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/11/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

extension String {
    static let outputConnector: String = "-"
}

extension URLRequest {

    func getURL() -> URL? {
        return url
    }

    func getQueryItems() -> [ElementsURLItem] {
        guard let url = url else { return [] }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else {
                return []
        }
        return queryItems.map { ElementsURLItem(name: $0.name, value: $0.value ?? "", originName: $0.name, originValue: $0.value ?? "") }
    }

    func getPath() -> String {
        return url?.path ?? String.notApplicable
    }

    func getHttpMethod() -> String {
        return httpMethod ?? String.notApplicable
    }

    func getCachePolicy() -> String {
        switch cachePolicy {
        case .useProtocolCachePolicy: return "UseProtocolCachePolicy"
        case .reloadIgnoringLocalCacheData: return "ReloadIgnoringLocalCacheData"
        case .reloadIgnoringLocalAndRemoteCacheData: return "ReloadIgnoringLocalAndRemoteCacheData"
        case .returnCacheDataElseLoad: return "ReturnCacheDataElseLoad"
        case .returnCacheDataDontLoad: return "ReturnCacheDataDontLoad"
        case .reloadRevalidatingCacheData: return "ReloadRevalidatingCacheData"
        @unknown default: return "Unknown \(cachePolicy)"
        }
    }

    func getTimeout() -> String {
        return String(Double(timeoutInterval))
    }

    func getHeaders() -> [ElementsURLItem] {
        let fields = allHTTPHeaderFields ?? [:]
        return fields.map { ElementsURLItem(name: $0.key, value: $0.value, originName: $0.key, originValue: $0.value) }
    }

    func getBody() -> Data {
        if let httpBody = httpBody {
            return httpBody
        }
        if let httpBodyStream = httpBodyStream {
            return (try? Data(reading: httpBodyStream)) ?? Data()
        }
        return Data()
    }

    func getCurl() -> String {
        guard let url = url else { return "" }
        let baseCommand = "curl \(url.absoluteString)"
        var command = [baseCommand]
        if let method = httpMethod {
            command.append("-X \(method)")
        }
        for item in getHeaders() {
            command.append("-H \u{22}\(item.name): \(item.value)\u{22}")
        }
        if let body = String(data: getBody(), encoding: .utf8) {
            command.append("-d \u{22}\(body)\u{22}")
        }
        return command.joined(separator: " ")
    }
}

extension URLResponse {

    func getStatus() -> Int {
        return (self as? HTTPURLResponse)?.statusCode ?? 999
    }

    func getHeaders() -> [AnyHashable: Any] {
        return (self as? HTTPURLResponse)?.allHeaderFields ?? [:]
    }
}

extension String {

    func appendToFile(filePath: String) {
        let contentToAppend = self
        if let fileHandle = FileHandle(forWritingAtPath: filePath) {
            /* Append to file */
            fileHandle.seekToEndOfFile()
            fileHandle.write(contentToAppend.data(using: String.Encoding.utf8) ?? Data())
        } else {
            /* Create new file */
            do {
                try contentToAppend.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Error creating \(filePath)")
            }
        }
    }

    func substring(with nsrange: NSRange) -> String? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return String(self[range])
    }

    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
}

extension CGFloat {

    func isEqualOnScreen(f2: CGFloat) -> Bool {
        var epsilon = CGFloat.leastNormalMagnitude
        if epsilon < 0.0 {
            epsilon = 1.0 / UIScreen.main.scale
        }
        return abs(self - f2) < epsilon
    }
}

extension Data {
    init(reading input: InputStream) throws {
        self.init()
        input.open()
        defer {
            input.close()
        }

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                //Stream error occured
                throw input.streamError!
            } else if read == 0 {
                //EOF
                break
            }
            self.append(buffer, count: read)
        }
    }
}
