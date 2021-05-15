//
//  FilterSectionController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 3/30/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import IGListKit
import UIKit

final class ElementsFilterModel: NSObject, ListDiffable {

    let item: ElementsFilterContainer

    init(item: ElementsFilterContainer) {
        self.item = item
    }

    func diffIdentifier() -> NSObjectProtocol {
        return item.section.displayID as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? ElementsFilterModel else { return false }
        return item == object.item
    }
}

final class FilterSectionController: ListSectionController {

    var model: ElementsFilterModel!
    private var currentHeaderCell: FilterTitleSectionCell?

    override init() {
        super.init()
        supplementaryViewSource = self
    }

    override func numberOfItems() -> Int {
        return model.item.uiType == .boolean ? 1 : model.item.selections.count
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        let style = model.item.uiType
        var height: CGFloat
        switch style {
        case .singleSelection, .multiSelection:
            height = FilterContentSectionCell.height
            if index == 0 || index == model.item.selections.count - 1 {
                height = FilterContentSectionCell.largeCellHeight
            }
        case .boolean:
            height = FilterToggleCell.height
        }
        return CGSize(width: width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        switch model.item.uiType {
        case .singleSelection, .multiSelection:
            return dequeueSingleMultiSelectionCell(at: index)
        case .boolean:
            return dequeueToggleCell(at: index)
        }
    }

    override func didUpdate(to object: Any) {
        model = object as? ElementsFilterModel
    }

    override func didSelectItem(at index: Int) {
        let type = model.item.uiType
        guard let cell = collectionContext?.cellForItem(
                at: index, sectionController: self
            ) as? FilterContentSectionCell,
            let selection = model.item.selections[safe: index] else {
            return
        }
        if type == .singleSelection {
            model.item.selectedItems.removeAll()
            deselectAllItems()
            cell.selectCell()
            model.item.selectedItems.insert(selection.keyID)
        } else {
            if model.item.selectedItems.contains(selection.keyID) {
                model.item.selectedItems.remove(selection.keyID)
                cell.deselectCell()
            } else {
                model.item.selectedItems.insert(selection.keyID)
                cell.selectCell()
            }
        }
    }

    private func deselectAllItems() {
        for cell in collectionContext?.visibleCells(for: self) ?? [] {
            if let cell = cell as? FilterContentSectionCell {
                cell.deselectCell()
            }
        }
    }
}

extension FilterSectionController {

    private func dequeueSingleMultiSelectionCell(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(
            of: FilterContentSectionCell.self, for: self, at: index
            ) as? FilterContentSectionCell, let selection = model.item.selections[safe: index] else {
                fatalError()
        }
        cell.setupCell(option: selection,
                       selected: model.item.selectedItems.contains(selection.keyID),
                       isFirstCell: index == 0,
                       isLastCell: index == (model.item.selections.count - 1))
        return cell
    }

    private func dequeueToggleCell(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(
            of: FilterToggleCell.self, for: self, at: index
            ) as? FilterToggleCell, let selection = model.item.selections.first else {
                fatalError()
        }
        cell.setupCell(title: selection.displayText, selected: model.item.selectedItems.contains(selection.keyID))
        cell.didSetSelectedState = { selected in
            if selected {
                self.model.item.selectedItems.insert(selection.keyID)
            } else {
                self.model.item.selectedItems.remove(selection.keyID)
            }
        }
        return cell
    }
}

extension FilterSectionController: ListSupplementaryViewSource {

    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionHeader]
    }

    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return headerView(atIndex: index)
        default:
            fatalError()
        }
    }

    func headerView(atIndex index: Int) -> UICollectionReusableView {
        guard let cell = collectionContext?.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            for: self,
            class: FilterTitleSectionCell.self,
            at: index) as? FilterTitleSectionCell else {
                fatalError()
        }
        cell.setupCell(title: NSLocalizedString(model.item.section.displayID, comment: ""))
        currentHeaderCell = cell
        return cell
    }

    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width, height: FilterTitleSectionCell.height)
    }
}
