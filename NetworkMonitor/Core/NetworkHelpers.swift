//
//  NetworkHelpers.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/11/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

struct NetworkStoragePath {
    static let documents = NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.documentDirectory,
        FileManager.SearchPathDomainMask.allDomainsMask, true
    ).first

    static let sessionLog = (documents as NSString?)?.appendingPathComponent("session.log")
}

extension Data {
    /// Data into file
    ///
    /// - Parameters:
    ///   - fileName: the Name of the file you want to write
    /// - Returns: Returns the URL where the new file is located in NSURL
    public func dataToFile(fileName: String) -> NSURL? {
        // Make a constant from the data
        let data = self
        guard let filePath = (NetworkStoragePath.documents as NSString?)?.appendingPathComponent(fileName) else {
            return nil
        }
        do {
            try data.write(to: URL(fileURLWithPath: filePath))
            return NSURL(fileURLWithPath: filePath)
        } catch {
            // Prints the localized description of the error from the do block
            print("Error writing the file: \(error.localizedDescription)")
        }
        return nil
    }
}

extension Float {

    public var networkMSDisplay: String {
        let ms = self * 1000
        return String(format: "%.0f ms", ms)
    }
}

extension Int64 {

    public var dataDisplayText: String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB, .useBytes]
        bcf.countStyle = .file
        let bodyLength = bcf.string(fromByteCount: self)
        return bodyLength
    }
}

extension ComparisonResult {

    public func reversed() -> ComparisonResult {
        switch self {
        case .orderedAscending:
            return .orderedDescending
        case .orderedDescending:
            return .orderedAscending
        case .orderedSame:
            return self
        }
    }
}

extension NSRange {

    public func contains(index: Int) -> Bool {
        return index >= location && index <= (location + length)
    }

    public func contains(range: NSRange) -> Bool {
        return location <= range.location && (location + length >= range.location + range.length)
    }

    public func generateRangeWith(offset: Int) -> NSRange {
        let newLocation = location + offset
        let newRange = NSRange(location: newLocation, length: length)
        return newRange
    }
}
