//
//  NetworkStatisticsItemSectionController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import IGListKit
import UIKit

open class NetworkStatisticsItemSectionController: ListSectionController {

    struct Constants {
        let itemCountPerScreen: CGFloat = 3
        let spaceBetweenIems: CGFloat = 10
    }

    private var model: NetworkStatisticsItemModel!
    private let constants = Constants()

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
    }

    override open func numberOfItems() -> Int {
        return 1
    }

    override open func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        let itemWidth = width / constants.itemCountPerScreen
        return CGSize(width: itemWidth, height: NetworkStatisticsCell.height)
    }

    override open func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(
            of: NetworkStatisticsCell.self,
            for: self,
            at: index) as? NetworkStatisticsCell else {
                fatalError()
        }
        cell.setupCell(title: model.title, value: model.value)
        return cell
    }

    override open func didUpdate(to object: Any) {
        model = object as? NetworkStatisticsItemModel
    }
}
