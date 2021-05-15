//
//  NetworkStatisticsSectionController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import IGListKit
import UIKit

final class NetworkStatisticsItemModel: NSObject, ListDiffable {

    let title: String
    let value: String

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    func diffIdentifier() -> NSObjectProtocol {
        return title as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? NetworkStatisticsItemModel else { return false }
        return title == object.title && value == object.value
    }
}

final class NetworkStatisticsItemsModel: NSObject, ListDiffable {

    let items: [NetworkStatisticsItemModel]

    init(items: [NetworkStatisticsItemModel]) {
        self.items = items
    }

    func diffIdentifier() -> NSObjectProtocol {
        return "NetworkStatisticsItemsModel" as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? NetworkStatisticsItemsModel else { return false }
        return items == object.items
    }
}

open class NetworkStatisticsSectionController: ListSectionController {

    private var model: NetworkStatisticsItemsModel!
    private var currentScrollOffset: CGPoint = .zero

    private lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(),
                                  viewController: self.viewController)
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        return adapter
    }()

    override public init() {
        super.init()
    }

    override open func numberOfItems() -> Int {
        return 1
    }

    override open func sizeForItem(at index: Int) -> CGSize {
        let width: CGFloat = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width, height: NetworkStatisticsCollectionViewCell.height)
    }

    override open func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(
            of: NetworkStatisticsCollectionViewCell.self,
            for: self,
            at: index) as? NetworkStatisticsCollectionViewCell else {
                fatalError()
        }
        adapter.collectionView = cell.collectionView
        adapter.reloadData(completion: nil)
        cell.collectionView.setContentOffset(currentScrollOffset, animated: false)
        return cell
    }

    override open func didUpdate(to object: Any) {
        model = object as? NetworkStatisticsItemsModel
    }
}

extension NetworkStatisticsSectionController: ListAdapterDataSource {

    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var diffableItems: [ListDiffable] = []
        for item in model.items {
            diffableItems.append(item)
        }
        return diffableItems
    }

    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let controller = NetworkStatisticsItemSectionController()
        return controller
    }

    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension NetworkStatisticsSectionController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentScrollOffset = scrollView.contentOffset
    }
}
