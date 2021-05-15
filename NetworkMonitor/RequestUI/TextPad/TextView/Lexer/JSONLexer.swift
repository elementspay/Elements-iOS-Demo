//
//  JSONLexer.swift
//
//
//  Created by Marvin Zhan on 11/13/19.
//

import Foundation
import UIKit

public class JSONLexer: SourceCodeRegexLexer {

    lazy var generators: [TokenGenerator] = {
        var generators = [TokenGenerator?]()
        generators.append(regexGenerator(#"-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?"#, tokenType: .number))
        generators.append(regexGenerator("\\.[A-Za-z_]+\\w*", tokenType: .identifier))
        generators.append(regexGenerator("(/\\*)(.*)(\\*/)", options: [.dotMatchesLineSeparators], tokenType: .comment))
        generators.append(regexGenerator(#"[:]\s(\".*\")"#, tokenType: .string))
        generators.append(regexGenerator(#"(?m)^[ ]*([^\r\n:]+?)\s*:"#, tokenType: .key))
        generators.append(regexGenerator("(\"\"\")(.*?)(\"\"\")", options: [.dotMatchesLineSeparators], tokenType: .string))
        generators.append(regexGenerator(#"true|false|null"#, tokenType: .boolean))

        return generators.compactMap({ $0 })
    }()

    public func generators(source: String) -> [TokenGenerator] {
        return generators
    }
}
