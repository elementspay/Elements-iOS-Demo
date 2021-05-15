//
//  NetworkRequestDetailBasicInfoSectionController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import IGListKit
import UIKit

final class NetworkRequestDetailBasicInfoModel: NSObject, ListDiffable {

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

open class NetworkRequestDetailBasicInfoSectionController: ListSectionController, Themeable {

    struct Constants {}

    private var model: NetworkRequestDetailBasicInfoModel!
    private let constants = Constants()

    override public init() {
        super.init()
        ElementsTheme.manager.register(themeable: self)
    }

    func apply(theme: ElementsTheme) {
        collectionContext?.performBatch(animated: true, updates: { context in
            context.reload(self)
        })
    }

    override open func numberOfItems() -> Int {
        return 1
    }

    override open func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        return CGSize(
            width: width,
            height: NetworkRequestDetailBasicInfoCell.calcHeight(containerWidth: width, text: model.item.value)
        )
    }

    override open func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(
            of: NetworkRequestDetailBasicInfoCell.self,
            for: self, at: index
            ) as? NetworkRequestDetailBasicInfoCell  else {
                fatalError()
        }
        cell.setupCell(title: model.item.title, value: model.item.value, valueColor: model.item.valueColor)
        return cell
    }

    override open func didUpdate(to object: Any) {
        model = object as? NetworkRequestDetailBasicInfoModel
    }
}
