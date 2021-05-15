//
//  NetworkRequestDetailAdvanceInfoSectionController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import IGListKit
import UIKit

final class NetworkRequestDetailAdvanceInfoModel: NSObject, ListDiffable {

    let item: NetworkRequestDetailItemModel

    init(item: NetworkRequestDetailItemModel) {
        self.item = item
    }

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}

open class NetworkRequestDetailAdvanceInfoSectionController: ListSectionController {

    struct Constants {}

    private var model: NetworkRequestDetailAdvanceInfoModel!
    private let constants = Constants()

    override open func numberOfItems() -> Int {
        return 1
    }

    override open func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width, height: NetworkRequestDetailAdvanceInfoCell.Constants.height)
    }

    override open func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(
            of: NetworkRequestDetailAdvanceInfoCell.self,
            for: self, at: index
        ) as? NetworkRequestDetailAdvanceInfoCell else {
                fatalError()
        }
        cell.setupCell(title: model.item.title, value: model.item.value)
        return cell
    }

    override open func didUpdate(to object: Any) {
        model = object as? NetworkRequestDetailAdvanceInfoModel
    }

    override open func didSelectItem(at index: Int) {
        model.item.selectedAction?(model.item.advanceDataType)
    }
}
