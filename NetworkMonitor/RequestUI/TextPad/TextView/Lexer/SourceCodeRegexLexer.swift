//
//  SourceCodeRegexLexer.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/13/19.
//

import UIKit
public protocol SourceCodeRegexLexer: RegexLexer {
}

extension RegexLexer {

    func regexGenerator(_ pattern: String,
                        options: NSRegularExpression.Options = [],
                        transformer: @escaping TokenTransformer) -> TokenGenerator? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return nil
        }
        return .regex(RegexTokenGenerator(regularExpression: regex, tokenTransformer: transformer))
    }
}

extension SourceCodeRegexLexer {

    func regexGenerator(_ pattern: String, options: NSRegularExpression.Options = [], tokenType: SourceCodeTokenType) -> TokenGenerator? {

        return regexGenerator(pattern, options: options, transformer: { (range) -> Token in
            return SimpleSourceCodeToken(type: tokenType, range: range)
        })
    }

    func keywordGenerator(_ words: [String], tokenType: SourceCodeTokenType) -> TokenGenerator {
        return .keywords(KeywordTokenGenerator(keywords: words, tokenTransformer: { (range) -> Token in
            return SimpleSourceCodeToken(type: tokenType, range: range)
        }))
    }
}
