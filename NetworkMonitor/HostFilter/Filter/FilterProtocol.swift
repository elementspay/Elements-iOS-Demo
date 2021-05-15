//
//  ilterProtocol.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 9/11/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

typealias ElementsFilterSelection = (keyID: String, displayText: String)

protocol ElementsFilterSection {
    var displayID: String { get }
    var toServerID: String { get }
}

enum ElementsFilterToolTipPopupStyle {
    case fromPoint
    case fromBottom
}

enum ElementsFilterUIType {
    case singleSelection
    case multiSelection
    case boolean
}

enum ElementsFilterBooleanType: String {
    case trueState = "true"
    case falseState = "false"
}

final class ElementsFilterContainer: Equatable {

    let section: ElementsFilterSection
    let selections: [ElementsFilterSelection]
    let uiType: ElementsFilterUIType
    var selectedItems: Set<String>
    var didSelectItem: ((String) -> Void)?
    var didUpdateSliderPercentage: ((Double, Double) -> Void)?

    private init(section: ElementsFilterSection,
                 uiType: ElementsFilterUIType,
                 selections: [ElementsFilterSelection] = [],
                 selectedItems: Set<String> = Set(),
                 didSelectItem: ((String) -> Void)? = nil,
                 didUpdateSliderPercentage: ((Double, Double) -> Void)? = nil) {
        self.section = section
        self.uiType = uiType
        self.selections = selections
        self.selectedItems = selectedItems
        self.didSelectItem = didSelectItem
        self.didUpdateSliderPercentage = didUpdateSliderPercentage
    }

    convenience init(section: ElementsFilterSection,
                            selections: [ElementsFilterSelection],
                            selectedItems: Set<String> = Set(),
                            didSelectItem: ((String) -> Void)? = nil) {
        self.init(section: section, uiType: .multiSelection, selections: selections, selectedItems: selectedItems, didSelectItem: didSelectItem)
    }

    convenience init(section: ElementsFilterSection,
                            selections: [ElementsFilterSelection],
                            selectedItem: String? = nil,
                            didSelectItem: ((String) -> Void)? = nil) {
        var set: Set<String> = Set()
        if let selectedItem = selectedItem {
            set.insert(selectedItem)
        }
        self.init(section: section, uiType: .singleSelection, selections: selections, selectedItems: set, didSelectItem: didSelectItem)
    }

    convenience init(section: ElementsFilterSection,
                     selection: ElementsFilterSelection,
                     selected: Bool,
                     didSelectItem: ((String) -> Void)? = nil) {
        var set: Set<String> = Set()
        if selected {
            set.insert(selection.keyID)
        }
        self.init(section: section, uiType: .boolean, selections: [selection], selectedItems: set, didSelectItem: didSelectItem)
    }
}

func == (lhs: ElementsFilterContainer, rhs: ElementsFilterContainer) -> Bool {
    return lhs.section.displayID == rhs.section.displayID
        && lhs.selections.mapToSet { $0.keyID } == rhs.selections.mapToSet { $0.keyID }
        && lhs.selectedItems == rhs.selectedItems
}

extension Array {

    func mapToSet<T: Hashable>(_ transform: (Element) -> T) -> Set<T> {
        var result = Set<T>()
        for item in self {
            result.insert(transform(item))
        }
        return result
    }
}
