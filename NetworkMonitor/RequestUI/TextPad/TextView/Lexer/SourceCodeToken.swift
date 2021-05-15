//
//  SourceCodeToken.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/13/19.
//

import Foundation
import UIKit

public enum SourceCodeTokenType {
    case plain
    case number
    case string
    case identifier
    case keyword
    case comment
    case key
    case boolean
}

protocol SourceCodeToken: Token {
    var type: SourceCodeTokenType { get }
}

extension SourceCodeToken {
    var isPlain: Bool {
        return type == .plain
    }
}

struct SimpleSourceCodeToken: SourceCodeToken {
    let type: SourceCodeTokenType
    let range: Range<String.Index>
}
