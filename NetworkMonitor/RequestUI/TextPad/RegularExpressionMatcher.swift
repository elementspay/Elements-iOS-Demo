//
//  ElementsRegularExpressionMatcher.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/13/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

open class ElementsRegularExpressionMatcher {

    public var targetString: String = ""
    public var pattern: String = ""
    public var options: NSRegularExpression.Options = .caseInsensitive

    private var indexOfCurrentMatch: Int?
    private var matchLocationsRange: NSRange?
    private let cachedMatchRanges: NSMutableArray
    private var targetStringCount: Int = 0

    private var numberOfMatches: Int {
        return cachedMatchRanges.count
    }

    private var regex: NSRegularExpression?
    public var circular: Bool = false

    public init() {
        self.cachedMatchRanges = NSMutableArray()
    }

    public func setTargetString(_ target: String) {
        self.targetString = target
        targetStringCount = target.count
    }

    public func match(pattern: String,
                      options: NSRegularExpression.Options = .caseInsensitive) throws {
        clear()
        self.pattern = pattern
        self.options = options
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            let range = NSRange(location: 0, length: targetStringCount)
            let now = Date()
            regex.enumerateMatches(in: targetString,
                                   options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                   range: range) { (result, _, _) in
                if let result = result {
                    cachedMatchRanges.add(result.range)
                }
            }
            print(Date().timeIntervalSince(now))
        } catch {
            throw(error)
        }
    }

    public func clear() {
        cachedMatchRanges.removeAllObjects()
        regex = nil
        indexOfCurrentMatch = nil
        matchLocationsRange = nil
    }
}

extension ElementsRegularExpressionMatcher {

    public func setIndexOfCurrentMatch(index: Int) {
        indexOfCurrentMatch = index < self.numberOfMatches ? index : nil
    }

    public func getIndexOfCurrentMatch() -> Int? {
        return indexOfCurrentMatch
    }

    public func getMatchLocationsRange() -> NSRange? {
        if let nonNilRange = matchLocationsRange {
            return nonNilRange
        }
        // swiftlint:disable empty_count
        if cachedMatchRanges.count > 0 {
            guard let firstMatch = cachedMatchRanges.firstObject as? NSRange, let lastMatch = cachedMatchRanges.lastObject as? NSRange else {
                return nil
            }
            return NSRange(location: firstMatch.location, length: lastMatch.location)
        }
        // swiftlint:enable empty_count
        return nil
    }

    public func getNumberOfMatches() -> Int {
        return cachedMatchRanges.count
    }

    public func getRangeOfCurrentMatch() -> NSRange? {
        guard let index = indexOfCurrentMatch else { return nil }
        return rangeOfMatchAt(index: index)
    }

    public func setRangeOfFirstMatch() -> NSRange? {
        return rangeOfMatchAt(index: 0)
    }

    @discardableResult
    public func setRangeOfFirstMatchIn(range: NSRange) -> NSRange? {
        guard let fisrtMatchedRange = indexOfFirstMatchIn(range: range) else { return nil }
        return rangeOfMatchAt(index: fisrtMatchedRange)
    }

    public func setRangeOfLastMatch() -> NSRange? {
        return rangeOfMatchAt(index: numberOfMatches - 1)
    }

    @discardableResult
    public func setRangeOfLastMatchInRange(range: NSRange) -> NSRange? {
        guard let lastMatchedRange = indexOfLastMatchIn(range: range) else { return nil }
        return rangeOfMatchAt(index: lastMatchedRange)
    }

    @discardableResult
    public func setRangeOfNextMatch() -> NSRange? {
        var result: NSRange?
        let current = indexOfCurrentMatch
        if current == nil || (circular && current == numberOfMatches - 1) {
            result = rangeOfMatchAt(index: 0)
        } else {
            guard let current = current else { return nil }
            result = rangeOfMatchAt(index: current + 1)
        }
        return result
    }

    @discardableResult
    public func setRangeOfPreviousMatch() -> NSRange? {
        var result: NSRange?
        let current = indexOfCurrentMatch
        if current == nil || (circular && current == 0) {
            result = rangeOfMatchAt(index: numberOfMatches - 1)
        } else {
            guard let current = current else { return nil }
            result = rangeOfMatchAt(index: current - 1)
        }
        return result
    }
}

extension ElementsRegularExpressionMatcher {

    private func rangeOfLastMatch() -> NSRange? {
        return rangeOfMatchAt(index: numberOfMatches - 1)
    }

    private func rangeOfLastMatchIn(range: NSRange) -> NSRange? {
        guard let lastPossibleIndex = indexOfLastMatchIn(range: range) else { return nil }
        return rangeOfMatchAt(index: lastPossibleIndex)
    }

    private func rangeOfMatchAt(index: Int) -> NSRange? {
        var result: NSRange?
        if index < numberOfMatches {
            indexOfCurrentMatch = index
            result = cachedMatchRanges.object(at: index) as? NSRange
        } else {
            indexOfCurrentMatch = nil
        }
        return result
    }

    private func indexOfFirstMatchIn(range: NSRange) -> Int? {
        let comparisonRange = NSRange(location: range.location, length: 0)
        let indexOfFirstPossibleRange = cachedMatchRanges.index(
            of: comparisonRange,
            inSortedRange: NSRange(location: 0, length: numberOfMatches),
            options: NSBinarySearchingOptions.insertionIndex,
            usingComparator: rangeComparator
        )
        guard indexOfFirstPossibleRange < numberOfMatches else {
            return nil
        }
        guard let possibleRange = cachedMatchRanges.object(at: indexOfFirstPossibleRange) as? NSRange else {
            return nil
        }
        return range.contains(range: possibleRange) ? indexOfFirstPossibleRange : nil
    }

    private func indexOfLastMatchIn(range: NSRange) -> Int? {
        let possibleRange = rangeOfMatchesIn(range: range)
        guard let searchedRange = possibleRange else {
            return nil
        }
        return searchedRange.location + searchedRange.length - 1
    }

    private func rangeOfMatchesIn(range: NSRange) -> NSRange? {
        let firstMatchIndex = indexOfFirstMatchIn(range: range)
        guard let index = firstMatchIndex else {
            return nil
        }
        var result = NSRange(location: index, length: 0)
        let cachedArrayRange = NSRange(location: index, length: numberOfMatches - index)
        for cachedObject in cachedMatchRanges.subarray(with: cachedArrayRange) {
            guard let cachedRange = cachedObject as? NSRange else {
                continue
            }
            if range.contains(range: cachedRange) {
                result.length += 1
            } else {
                break
            }
        }
        return result
    }

    func rangesOfMatchesIn(range: NSRange) -> [NSRange] {
        let possibleRangeIndex = rangeOfMatchesIn(range: range)
        guard let searchedRangeIndex = possibleRangeIndex else {
            return []
        }
        let subarray = cachedMatchRanges.subarray(with: searchedRangeIndex)
        var result: [NSRange] = []
        for match in subarray {
            guard let matchedRange = match as? NSRange else { continue }
            result.append(matchedRange)
        }
        return result
    }
}

extension ElementsRegularExpressionMatcher {

    private func rangeComparator(rangeA: Any, rangeB: Any) -> ComparisonResult {
        guard let rangeA = rangeA as? NSRange, let rangeB = rangeB as? NSRange else { return .orderedSame }
        var result = ComparisonResult.orderedSame
        if rangeA.location < rangeB.location {
            result = .orderedAscending
        } else if rangeA.location > rangeB.location {
            result = .orderedDescending
        } else if rangeA.length < rangeB.length {
            result = .orderedAscending
        } else if rangeA.length > rangeB.length {
            result = .orderedDescending
        }
        return result
    }
}
