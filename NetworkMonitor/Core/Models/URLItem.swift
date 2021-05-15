//
//  ElementsURLItem.swift
//
//
//  Created by Marvin Zhan on 12/12/19.
//

import UIKit

public final class ElementsURLItem: NSObject, NSCopying {

    public static func == (lhs: ElementsURLItem, rhs: ElementsURLItem) -> Bool {
        return lhs.id == rhs.id
    }

    let id: String
    let originName: String
    let originValue: String

    var name: String
    var value: String

    var isOverrided: Bool {
        return originName != name || originValue != value
    }

    init(id: String = UUID().uuidString,
         name: String,
         value: String,
         originName: String,
         originValue: String) {
        self.id = id
        self.originName = originName
        self.originValue = originValue
        self.name = name
        self.value = value
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let item = ElementsURLItem(
            id: id,
            name: name,
            value: value,
            originName: originName,
            originValue: originValue
        )
        return item
    }

    func transformToURLQueryItem() -> URLQueryItem {
        return URLQueryItem(name: name, value: value)
    }

    func resetName() {
        name = originName
    }

    func resetValue() {
        value = originValue
    }
}
