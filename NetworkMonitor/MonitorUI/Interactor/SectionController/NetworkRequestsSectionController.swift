//
//  NetworkRequestsSectionController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import IGListKit
import UIKit

final class NetworkRequestDisplayModel: NSObject, ListDiffable {
    let id: String
    let status: String
    let statusColor: UIColor
    let method: String
    let path: String
    let time: String
    let responseTime: String
    let responseTimeColor: UIColor
    let isOverrided: Bool
    let requestSelected: ((String) -> Void)?

    init(id: String,
         status: String,
         statusColor: UIColor,
         method: String,
         path: String,
         time: String,
         responseTime: String,
         responseTimeColor: UIColor,
         isOverrided: Bool,
         requestSelected: ((String) -> Void)?) {
        self.id = id
        self.status = status
        self.statusColor = statusColor
        self.method = method
        self.path = path
        self.time = time
        self.responseTime = responseTime
        self.responseTimeColor = responseTimeColor
        self.isOverrided = isOverrided
        self.requestSelected = requestSelected
    }

    func diffIdentifier() -> NSObjectProtocol {
        return (id + path + time + (isOverrided ? "true" :
            "false")) as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? NetworkRequestDisplayModel else { return false }
        return status == object.status
            && statusColor == object.statusColor
            && method == object.method
            && path == object.path
            && time == object.time
            && responseTime == object.responseTime
            && responseTimeColor == object.responseTimeColor
            && isOverrided == object.isOverrided
    }
}

final class NetworkRequestsModel: NSObject, ListDiffable {

    let items: [NetworkRequestDisplayModel]

    init(items: [NetworkRequestDisplayModel]) {
        self.items = items
    }

    func diffIdentifier() -> NSObjectProtocol {
        return "NetworkRequestsModel" as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? NetworkRequestsModel else { return false }
        return items == object.items
    }
}

open class NetworkRequestsSectionController: ListBindingSectionController<ListDiffable> {

    struct Constants {}

    private var model: NetworkRequestsModel!
    private let constants = Constants()

    static let spaceBetweenIems: CGFloat = 10

    override open func numberOfItems() -> Int {
        return model.items.count
    }

    override open func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width, height: NetworkRequestItemCell.Constants.height)
    }

    override open func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(
            of: NetworkRequestItemCell.self,
            for: self,
            at: index) as? NetworkRequestItemCell, let item = model.items[safe: index] else {
                fatalError()
        }
        cell.setupCell(model: item)
        return cell
    }

    override open func didUpdate(to object: Any) {
        model = object as? NetworkRequestsModel
    }

    override open func didSelectItem(at index: Int) {
        guard let item = model.items[safe: index] else {
            return
        }
        item.requestSelected?(item.id)
    }
}

open class NetworkRequestSectionController: ListSectionController {

    struct Constants {}

    private var model: NetworkRequestDisplayModel!
    private let constants = Constants()

    override open func numberOfItems() -> Int {
        return 1
    }

    override open func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width, height: NetworkRequestItemCell.Constants.height)
    }

    override open func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(
            of: NetworkRequestItemCell.self,
            for: self,
            at: index) as? NetworkRequestItemCell else {
                fatalError()
        }
        cell.setupCell(model: model)
        return cell
    }

    override open func didUpdate(to object: Any) {
        model = object as? NetworkRequestDisplayModel
    }

    override open func didSelectItem(at index: Int) {
        model.requestSelected?(model.id)
    }
}

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
