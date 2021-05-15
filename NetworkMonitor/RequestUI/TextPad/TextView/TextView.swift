//
//  ElementsTextView.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

public protocol TextViewSourceDelegate: class {
    func didChangeText(_ syntaxTextView: ElementsTextView)
    func didChangeSelectedRange(_ syntaxTextView: ElementsTextView, selectedRange: NSRange)
    func textViewDidBeginEditing(_ syntaxTextView: ElementsTextView)
    func lexerForSource(_ source: String) -> Lexer
}

open class ElementsTextView: UITextView {

    struct Constants {
        let scrollOffsetAdjustment: CGFloat = 32
        let primaryHighlightedColor: UIColor = ApplicationDependency.manager.theme.colors.themeColor.withAlphaComponent(0.5)
        let secondaryHighlightedColor: UIColor = ApplicationDependency.manager.theme.colors.themeColor
        let highlightedCornerRadius: CGFloat = 4
        let initialTextFont: UIFont = ApplicationDependency.manager.theme.fonts.primaryTextFont

        static let searchIndexInitState = Int.max
    }

    private let regexMatcher: ElementsRegularExpressionMatcher
    private var textContainerSubview: UIView?
    private var cachedRange: NSRange?
    private var cachedTokens: [CachedToken]?
    private var searchIndex: Int = Constants.searchIndexInitState
    private var performedNewScroll: Bool = false
    private var searching: Bool = false
    private var searchVisibleRange: Bool = false

    public var theme: SyntaxColorTheme? {
        didSet {
            guard let theme = theme else {
                return
            }
            cachedThemeInfo = nil
            backgroundColor = theme.backgroundColor
            font = theme.font
            didUpdateText()
        }
    }

    private var cachedThemeInfo: ThemeInfo?
    private var themeInfo: ThemeInfo? {
        if let cached = cachedThemeInfo {
            return cached
        }
        guard let theme = theme else {
            return nil
        }
        let spaceAttrString = NSAttributedString(string: " ", attributes: [.font: theme.font])
        let spaceWidth = spaceAttrString.size().width
        let info = ThemeInfo(theme: theme, spaceWidth: spaceWidth)
        cachedThemeInfo = info
        return info
    }

    private var highlightsByRangeDict: NSMutableDictionary
    private var primaryHighlightsCache: NSMutableArray
    private var secondaryHighlightsCache: NSMutableOrderedSet
    private var autoRefreshTimer: Timer?
    private var textCount: Int = 0

    public var animatedSearch: Bool = true
    public var circularSearch: Bool = true
    public var displayPosition: TextViewSearchDisplayPosition = .middle
    public var searchOptions: NSRegularExpression.Options = .caseInsensitive
    public var restrictedSearchRange: NSRange?
    public var maxHighlightedMatches: Int = 100
    public var scrollAutoRefreshDeplay: TimeInterval = 0.2

    weak var sourceDelegate: TextViewSourceDelegate?
    private let constants = Constants()

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        regexMatcher = ElementsRegularExpressionMatcher()
        primaryHighlightsCache = NSMutableArray()
        highlightsByRangeDict = NSMutableDictionary()
        secondaryHighlightsCache = NSMutableOrderedSet()
        super.init(frame: frame, textContainer: textContainer)
        delegate = self
        initiaizeHightlightsCache()
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setCircularSearch(enabled: Bool) {
        circularSearch = enabled
        regexMatcher.circular = enabled
    }

    private func resetAutoRefreshTimer() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }

    override open func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        super.setContentOffset(contentOffset, animated: animated)
        adjustUIWhenScrolling()
    }

    public func adjustUIWhenScrolling() {
        performedNewScroll = true
        if !searchVisibleRange {
            searchVisibleRange = panGestureRecognizer.velocity(in: self).y != 0
        }
        if searching && scrollAutoRefreshDeplay > 0, autoRefreshTimer == nil {
            autoRefreshTimer = Timer(timeInterval: scrollAutoRefreshDeplay, target: self, selector: #selector(highlightOccurrencesInMaskedVisibleRange), userInfo: nil, repeats: true)
            RunLoop.main.add(autoRefreshTimer!, forMode: RunLoop.Mode.tracking)
        }
    }

    public func setText(_ text: String) {
        textCount = text.count
        regexMatcher.setTargetString(text)
        didUpdateText()
    }

    private func setup() {
        autocapitalizationType = .none
        keyboardType = .default
        autocorrectionType = .no
        spellCheckingType = .no
        if #available(iOS 11.0, *) {
            smartQuotesType = .no
            smartInsertDeleteType = .no
        }
    }
}

extension ElementsTextView {

    public func matchedString() -> String? {
        guard let range = rangeOfMatchedString() else { return nil }
        return textCount >= range.location + range.length ? text.substring(with: range) : nil
    }

    public func indexOfMatchedString() -> Int? {
        return regexMatcher.getIndexOfCurrentMatch()
    }

    public func numberOfMatches() -> Int? {
        return regexMatcher.getNumberOfMatches()
    }

    public func rangeOfMatchedString() -> NSRange? {
        guard let rangeOfCurrentMatch = regexMatcher.getRangeOfCurrentMatch(),
            let cachedRange = cachedRange else {
            return nil
        }
        return rangeOfCurrentMatch.generateRangeWith(offset: cachedRange.location)
    }
}

// MARK: - Search
extension ElementsTextView {

    public func resetSearch() {
        initiaizeHightlightsCache()
        resetAutoRefreshTimer()
        cachedRange = nil
        regexMatcher.clear()
        searchIndex = Constants.searchIndexInitState
        searching = false
        searchVisibleRange = false
    }

    func scrollToMatch(pattern: String) -> Bool {
        return scrollToMatch(pattern: pattern, searchDirection: .forward)
    }

    func scrollToMatch(pattern: String, searchDirection: TextViewSearchDirection) -> Bool {
        guard initializeSearchWith(pattern: pattern) else {
            return false
        }
        searching = true

        var newSearchIndex = Constants.searchIndexInitState
        if searchIndex != Constants.searchIndexInitState
            && regexMatcher.getMatchLocationsRange()?.contains(searchIndex) ?? false {
            newSearchIndex = searchIndex - (cachedRange?.location ?? 0)
        }
        // Matched
        if newSearchIndex == Constants.searchIndexInitState {
            if searchDirection == .forward {
                regexMatcher.setRangeOfNextMatch()
            } else {
                regexMatcher.setRangeOfPreviousMatch()
            }
        } else {
            if searchDirection == .forward {
                let range = NSRange(location: newSearchIndex, length: textCount - newSearchIndex)
                regexMatcher.setRangeOfFirstMatchIn(range: range)
            } else {
                regexMatcher.setRangeOfLastMatchInRange(range: NSRange(location: 0, length: searchIndex))
            }
            searchIndex = Constants.searchIndexInitState
        }

        let matchRange = rangeOfMatchedString()
        if let range = matchRange {
            searchVisibleRange = false
            scrollRangeToVisible(range: range, consideringInsets: true)
            highlightOccurrencesInMaskedVisibleRange()
        } else {
            searching = false
        }
        return matchRange != nil
    }

    public func scrollToString(target: String) -> Bool {
        return scrollToString(target: target, searchDirection: .forward)
    }

    @discardableResult
    public func scrollToString(target: String, searchDirection: TextViewSearchDirection) -> Bool {
        let stringToFind = NSRegularExpression.escapedPattern(for: target)
        // Improve automatic search on UITextField or UISearchBar text change
        if searching {
            let pattern = regexMatcher.pattern
            let stringToFindLength = stringToFind.count
            let patternLength = pattern.count
            if stringToFindLength != patternLength {
                let minLength = min(stringToFindLength, patternLength)
                let lowercasedStrigToFind = String(stringToFind[..<stringToFind.index(from: minLength)]).lowercased()
                let lowercasedPattern = String(pattern[..<pattern.index(from: minLength)]).lowercased()
                let matchedStringLocation = rangeOfMatchedString()?.location
                if lowercasedStrigToFind == lowercasedPattern, let location = matchedStringLocation {
                    searchIndex = location
                }
            }
        }
        let success = scrollToMatch(pattern: stringToFind, searchDirection: searchDirection)
        return success
    }

    private func initializeSearchWith(pattern: String) -> Bool {
        if pattern.isEmpty {
            resetSearch()
            return false
        }

        let textRange = NSRange(location: 0, length: textCount)
        var preparedSearchRange = textRange

        if let restrictedRange = restrictedSearchRange {
            preparedSearchRange = NSIntersectionRange(textRange, restrictedRange)
        }
        if preparedSearchRange.length == 0 && textCount != 0 {
            preparedSearchRange = textRange
        }

        let executeNewMatch = shouldExecuteNewMatch(pattern: pattern, range: preparedSearchRange)
        if executeNewMatch {
            regexMatcher.circular = circularSearch
            let success = executeSearch(
                pattern: pattern,
                preparedSearchRange: preparedSearchRange,
                isSameSearchRange: cachedRange == preparedSearchRange
            )
            guard success else { return false }
        }
        initiaizeHightlightsCache()
        if executeNewMatch {
            initializeSecondaryHighlights()
        }
        return true
    }

    private func shouldExecuteNewMatch(pattern: String, range: NSRange) -> Bool {
        let isSamePattern = pattern == regexMatcher.pattern
        let isSameOptions = searchOptions == regexMatcher.options
        let isSameSearchRange = cachedRange == range
        let executeMatch = !(isSamePattern && isSameOptions && isSameSearchRange)
        return executeMatch
    }

    private func executeSearch(pattern: String, preparedSearchRange: NSRange, isSameSearchRange: Bool) -> Bool {
        do {
            try regexMatcher.match(pattern: pattern, options: searchOptions)
            cachedRange = preparedSearchRange
        } catch {
            return false
        }
        return true
    }
}

extension ElementsTextView {

    private func generateHighlightedRect(frame: CGRect) -> UIView {
        let highlightedView = UIView(frame: frame)
        highlightedView.layer.cornerRadius = constants.highlightedCornerRadius
        highlightedView.backgroundColor = constants.secondaryHighlightedColor.withAlphaComponent(0.3)
        secondaryHighlightsCache.add(highlightedView)
        addSubview(highlightedView)
        return highlightedView
    }

    private func generateHighlightedRectAt(textRange: UITextRange?) -> NSMutableArray {
        guard let textRange = textRange else {
            return NSMutableArray()
        }
        let highlightsForRange = NSMutableArray()
        var prevRect = CGRect.zero
        let highlightedRects = selectionRects(for: textRange)
        for selectionRect in highlightedRects {
            let currentRect = selectionRect.rect
            if currentRect.origin.y.isEqualOnScreen(f2: prevRect.origin.y) && currentRect.origin.x.isEqualOnScreen(f2: prevRect.maxX) && currentRect.size.height.isEqualOnScreen(f2: prevRect.size.height) {
                prevRect = CGRect(
                    x: prevRect.origin.x, y: prevRect.origin.y,
                    width: prevRect.size.width, height: prevRect.size.height
                )
            } else {
                highlightsForRange.add(generateHighlightedRect(frame: prevRect))
                prevRect = currentRect
            }
        }
        highlightsForRange.add(generateHighlightedRect(frame: prevRect))
        return highlightsForRange
    }

    @objc
    private func highlightOccurrencesInMaskedVisibleRange() {
        guard searching else {
            return
        }
        guard performedNewScroll else {
            setPrimaryHighlightAt(range: rangeOfMatchedString())
            return
        }
        // Initial data
        let visibleRangeInfo = visibleRangeConsideringInset(consider: true)
        guard let cachedRange = cachedRange else {
            setPrimaryHighlightAt(range: rangeOfMatchedString())
            return
        }
        let visibleRange = visibleRangeInfo.0
        let visibleStartPosition = visibleRangeInfo.1 ?? beginningOfDocument
        // Perform search in masked range
        let cachedRangeLocation = cachedRange.location
        let maskedRange = NSIntersectionRange(cachedRange, visibleRange).generateRangeWith(offset: -cachedRangeLocation)
        let rangeValues = NSMutableArray()

        for rangeValue in regexMatcher.rangesOfMatchesIn(range: maskedRange) {
            rangeValues.add(rangeValue.generateRangeWith(offset: cachedRangeLocation))
        }
        // ADD SECONDARY HIGHLIGHTS
        if rangeValues.count > 0, let rangesArray = rangeValues.mutableCopy() as? NSMutableArray {
            // Remove already present highlights
            let indexesToRemove = NSMutableIndexSet()
            for (i, rangeValue) in rangeValues.enumerated() {
                if highlightsByRangeDict.object(forKey: rangeValue) != nil {
                    indexesToRemove.add(i)
                }
            }
            rangesArray.removeObjects(at: indexesToRemove as IndexSet)
            indexesToRemove.removeAllIndexes()
            // Get text range of first result
            guard let firstRangeValue = rangesArray.firstObject as? NSRange else {
                updateSearchIndex(visibleRange: visibleRange)
                return
            }
            var previousRange = firstRangeValue
            var start = position(from: visibleStartPosition, offset: previousRange.location - visibleRange.location) ?? beginningOfDocument
            var end = position(from: start, offset: previousRange.length) ?? endOfDocument
            var textRangeLocal = textRange(from: start, to: end)
            // First range
            highlightsByRangeDict.setObject(generateHighlightedRectAt(textRange: textRangeLocal),
                                            forKey: firstRangeValue as NSCopying)
            rangesArray.removeObject(at: 0)
            for rangeValue in rangesArray {
                guard let range = rangeValue as? NSRange else {
                    continue
                }
                start = position(from: end, offset: range.location - (previousRange.location + previousRange.length)) ?? beginningOfDocument
                end = position(from: start, offset: range.length) ?? endOfDocument
                textRangeLocal = textRange(from: start, to: end)
                highlightsByRangeDict.setObject(generateHighlightedRectAt(textRange: textRangeLocal),
                                                forKey: range as NSCopying)
                previousRange = range
            }
            // Memory management
            let maxVal = min(maxHighlightedMatches, Int.max)
            let remaining = maxVal - highlightsByRangeDict.count
            if remaining < 0 {
                removeHighlightsTooFarFrom(range: visibleRange)
            }
        }
        // Eventually update searchIndex to match visible range
        updateSearchIndex(visibleRange: visibleRange)
    }

    private func updateSearchIndex(visibleRange: NSRange) {
        if searchVisibleRange {
            searchIndex = visibleRange.location
        }
        setPrimaryHighlightAt(range: rangeOfMatchedString())
    }

    private func visibleRangeConsideringInset(consider: Bool) -> (NSRange, UITextPosition?, UITextPosition?) {
        let visibleRect = visibleRectConsideringInset(consider: consider)
        let startPoint = visibleRect.origin
        let endPoint = CGPoint(x: visibleRect.maxX, y: visibleRect.maxY)

        let start = characterRange(at: startPoint)?.start
        let end = characterRange(at: endPoint)?.end

        var startOffset: Int = 0
        var length: Int = 0
        if let start = start {
            startOffset = offset(from: beginningOfDocument, to: start)
        }
        if let end = end {
            length = offset(from: start ?? beginningOfDocument, to: end)
        }

        let range = NSRange(location: startOffset, length: length)
        return (range, start, end)
    }

    private func visibleRectConsideringInset(consider: Bool) -> CGRect {
        var visibleRect = bounds
        if consider {
            visibleRect = visibleRect.inset(by: getTotalContentInset())
        }
        return visibleRect
    }
}

// MARK: - Hightlight search results.
extension ElementsTextView {

    private func initiaizeHightlightsCache() {
        initializePrimaryHighlights()
        initializeSecondaryHighlights()
    }

    private func initializePrimaryHighlights() {
        // Move primary highlights to secondary highlights cache
        for object in primaryHighlightsCache {
            guard let highlightView = object as? UIView else {
                continue
            }
            highlightView.backgroundColor = constants.secondaryHighlightedColor
            secondaryHighlightsCache.add(object)
        }
        primaryHighlightsCache.removeAllObjects()
    }

    private func initializeSecondaryHighlights() {
        for object in secondaryHighlightsCache {
            guard let highlightView = object as? UIView else {
                continue
            }
            highlightView.removeFromSuperview()
        }
        secondaryHighlightsCache.removeAllObjects()
        // Remove all objects in highlightsByRange, except rangeOfFoundString (primary)
        if primaryHighlightsCache.count > 0 {
            if let range = rangeOfMatchedString(),
                let primaryHighlights = highlightsByRangeDict.object(forKey: range) {
                highlightsByRangeDict.removeAllObjects()
                highlightsByRangeDict.setObject(primaryHighlights, forKey: range as NSCopying)
            }
        } else {
            highlightsByRangeDict.removeAllObjects()
        }
        // Allow highlights to be refreshed
        performedNewScroll = true
    }
}

extension ElementsTextView: UITextViewDelegate {

    public func textViewDidBeginEditing(_ textView: UITextView) {
        guard let textView = textView as? ElementsTextView else { return }
        sourceDelegate?.textViewDidBeginEditing(textView)
    }

    public func textViewDidChange(_ textView: UITextView) {
        guard let textView = textView as? ElementsTextView else { return }
        sourceDelegate?.didChangeText(textView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollEnded()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adjustUIWhenScrolling()
    }

    private func didUpdateText() {
        cachedTokens = nil
        setNeedsDisplay()

        if let delegate = sourceDelegate {
            colorTextView(lexerForSource: { (source) -> Lexer in
                return delegate.lexerForSource(source)
            })
        }
    }
}

extension ElementsTextView {

    public func scrollRangeToVisible(range: NSRange, consideringInsets: Bool) {
        // Calculates rect for range
        layoutManager.ensureLayout(for: textContainer)
        let startPosition = position(from: beginningOfDocument, offset: range.location) ?? beginningOfDocument
        let endPosition = position(from: startPosition, offset: range.length) ?? endOfDocument
        if let textRange: UITextRange = self.textRange(from: startPosition, to: endPosition) {
            let rect = firstRect(for: textRange)
            scrollRectToVisible(rect: rect, animated: true, consideringInsets: consideringInsets)
        }
    }

    private func getTotalContentInset() -> UIEdgeInsets {
        var newContentInset = contentInset
        newContentInset.top += textContainerInset.top
        newContentInset.bottom += textContainerInset.bottom
        newContentInset.left += textContainerInset.left
        newContentInset.right += textContainerInset.right
        return newContentInset
    }

    // Returns visible rect, eventually considering insets
    private func visibleRectConsideringInsets() -> CGRect {
        var visibleRect = bounds
        visibleRect.origin.x += contentInset.left
        visibleRect.origin.y += contentInset.top
        visibleRect.size.width -= (contentInset.left + contentInset.right)
        visibleRect.size.height -= (contentInset.top + contentInset.bottom)
        return visibleRect
    }

    // Scrolls to visible rect, eventually considering insets
    private func scrollRectToVisible(rect: CGRect, animated: Bool, consideringInsets: Bool) {
        let scrollContentInset = consideringInsets ? getTotalContentInset() : UIEdgeInsets.zero
        let visibleRect = visibleRectConsideringInsets()
        var toleranceArea = visibleRect
        var originY = rect.origin.y - scrollContentInset.top

        switch displayPosition {
        case .top:
            toleranceArea.size.height = rect.size.height * 1.5
        case .middle:
            toleranceArea.size.height = rect.size.height * 1.5
            toleranceArea.origin.y += (visibleRect.size.height - toleranceArea.size.height) * 0.5
            originY -= (visibleRect.size.height - rect.size.height) * 0.5
        case .bottom:
            toleranceArea.size.height = rect.size.height * 1.5
            toleranceArea.origin.y += (visibleRect.size.height - toleranceArea.size.height)
            originY -= (visibleRect.size.height - rect.size.height)
        case .none:
            if rect.origin.y >= visibleRect.origin.y {
                originY -= visibleRect.size.height - rect.size.height
            }
        }
        if !toleranceArea.contains(rect) {
            scrollToY(originY, animated: animated, consideringInsets: consideringInsets)
        }
    }

    @objc
    func scrollEnded() {
        highlightOccurrencesInMaskedVisibleRange()
        resetAutoRefreshTimer()
        performedNewScroll = false
    }

    // Scrolls to y coordinate without breaking the frame and (eventually) insets
    private func scrollToY(_ y: CGFloat, animated: Bool, consideringInsets: Bool) {
        var minPoint: CGFloat = 0.0
        var maxPoint: CGFloat = max(contentSize.height - bounds.size.height, 0)
        if consideringInsets {
            let totalContentInset = getTotalContentInset()
            minPoint -= totalContentInset.top
            maxPoint += totalContentInset.bottom
        }
        // Calculates new content offset
        var adjustedContentOffset = contentOffset
        if y > maxPoint {
            adjustedContentOffset.y = maxPoint
        } else if y < minPoint {
            adjustedContentOffset.y = minPoint
        } else {
            adjustedContentOffset.y = y
        }
        setContentOffset(CGPoint(x: 0, y: adjustedContentOffset.y), animated: true)
    }

    private func setPrimaryHighlightAt(range: NSRange?) {
        guard let range = range else { return }
        initializePrimaryHighlights()
        let highlightsForRange = highlightsByRangeDict.object(forKey: range) as? NSMutableArray
        for object in highlightsForRange ?? [] {
            guard let view = object as? UIView else {
                continue
            }
            view.backgroundColor = constants.primaryHighlightedColor
            primaryHighlightsCache.add(view)
            secondaryHighlightsCache.remove(view)
        }
    }

    private func removeHighlightsTooFarFrom(range: NSRange) {
        let tempMin = range.location - range.length
        let min = tempMin > 0 ? tempMin : 0
        let max = min + 3 * range.length
        // Scan highlighted ranges
        var keysToRemove: [Any] = []
        for kv in highlightsByRangeDict {
            guard let key = kv.key as? NSRange, let value = kv.value as? NSMutableArray, let matchedLocation = rangeOfMatchedString() else {
                continue
            }
            let location = key.location
            if (location < min || location > max) && location != matchedLocation.location {
                for object in value {
                    guard let cachedView = object as? UIView else {
                        continue
                    }
                    cachedView.removeFromSuperview()
                    secondaryHighlightsCache.remove(object)
                }
                keysToRemove.append(key)
            }
        }
        highlightsByRangeDict.removeObjects(forKeys: keysToRemove)
    }
}

public extension ElementsTextView {

    private func colorTextView(lexerForSource: (String) -> Lexer) {
        guard let source = text else { return }
        let tokens: [Token]
        if let cachedTokens = cachedTokens {
            updateAttributes(textStorage: textStorage, cachedTokens: cachedTokens, source: source)
        } else {
            guard let theme = self.theme else {
                return
            }
            guard let themeInfo = self.themeInfo else {
                return
            }
            font = theme.font
            let lexer = lexerForSource(source)
            tokens = lexer.getTokens(input: source)
            let cachedTokens: [CachedToken] = tokens.map {
                let nsRange = source.nsRange(fromRange: $0.range)
                return CachedToken(token: $0, nsRange: nsRange)
            }
            self.cachedTokens = cachedTokens
            createAttributes(
                theme: theme,
                themeInfo: themeInfo,
                textStorage: textStorage,
                cachedTokens: cachedTokens,
                source: source
            )
        }
    }

    private func updateAttributes(textStorage: NSTextStorage,
                                  cachedTokens: [CachedToken],
                                  source: String) {
    }

    private func createAttributes(theme: SyntaxColorTheme,
                                  themeInfo: ThemeInfo,
                                  textStorage: NSTextStorage,
                                  cachedTokens: [CachedToken],
                                  source: String) {
        textStorage.beginEditing()
        var attributes = [NSAttributedString.Key: Any]()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 2.0

        let wholeRange = NSRange(location: 0, length: (source as NSString).length)
        attributes[.paragraphStyle] = paragraphStyle

        for (attr, value) in theme.globalAttributes() {
            attributes[attr] = value
        }
        textStorage.setAttributes(attributes, range: wholeRange)
        for cachedToken in cachedTokens where !cachedToken.token.isPlain {
            let token = cachedToken.token
            let range = cachedToken.nsRange
            textStorage.addAttributes(theme.attributes(for: token), range: range)
        }
        textStorage.endEditing()
    }
}
