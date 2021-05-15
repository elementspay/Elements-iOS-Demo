//
//  NetworkRequestInfoSectionController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import IGListKit
import UIKit

final class NetworkRequestInfoPresentingModel: NSObject, ListDiffable {

    let id: String
    var title: String
    var value: String
    var originTitle: String
    var originValue: String

    var isDifferentFromOrigin: Bool {
        return title != originTitle || value != originValue
    }

    var titleColor: UIColor {
        return title == originTitle
            ? ApplicationDependency.manager.theme.colors.secondaryTextColorLightCanvas
            : ColorPlate.red
    }
    var valueColor: UIColor {
        return value == originValue
            ? ApplicationDependency.manager.theme.colors.primaryTextColorLightCanvas
            : ColorPlate.red
    }

    let keyUpdated: ((String, String) -> Void)?
    let valueUpdated: ((String, String) -> Void)?
    let resetAction: ((String) -> Void)?

    init(id: String,
         title: String,
         value: String,
         originTitle: String,
         originValue: String,
         keyUpdated: ((String, String) -> Void)?,
         valueUpdated: ((String, String) -> Void)?,
         resetAction: ((String) -> Void)?) {
        self.id = id
        self.title = title
        self.value = value
        self.originTitle = originTitle
        self.originValue = originValue
        self.keyUpdated = keyUpdated
        self.valueUpdated = valueUpdated
        self.resetAction = resetAction
    }

    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? NetworkRequestInfoPresentingModel else { return false }
        return id == object.id
            && title == object.title
            && value == object.value
            && originTitle == object.originTitle
            && originValue == object.originValue
    }
}

open class NetworkRequestInfoSectionController: ListSectionController {

    private var model: NetworkRequestInfoPresentingModel!

    override open func numberOfItems() -> Int {
        return 1
    }

    override open func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        let height = NetworkRequestInfoCell.calcHeight(containerWidth: width, title: model.title, value: model.value, resetState: model.isDifferentFromOrigin)
        return CGSize(width: width, height: height)
    }

    override open func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(
            of: NetworkRequestInfoCell.self,
            for: self, at: index
            ) as? NetworkRequestInfoCell else {
                fatalError()
        }
        cell.setupCell(title: model.title, value: model.value, showResetButton: model.isDifferentFromOrigin)
        cell.updateTextColor(titleColor: model.titleColor, valueColor: model.valueColor)
        cell.delegate = self
        cell.resetAction = { self.model.resetAction?(self.model.id) }
        return cell
    }

    override open func didUpdate(to object: Any) {
        model = object as? NetworkRequestInfoPresentingModel
    }
}

extension NetworkRequestInfoSectionController: NetworkRequestInfoCellDelegate {

    func textViewEndEditing(text: String, tag: Int) {
        if tag == 0 {
            model.keyUpdated?(model.id, text)
            model.title = text
        }
        if tag == 1 {
            model.valueUpdated?(model.id, text)
            model.value = text
        }
        if let cell = collectionContext?.cellForItem(at: 0, sectionController: self) as? NetworkRequestInfoCell {
            cell.updateTextColor(titleColor: model.titleColor, valueColor: model.valueColor)
            cell.updateResetButtonState(enabled: model.isDifferentFromOrigin)
        }
    }

    func cellHeightDidChange() {
        UIView.animate(withDuration: 0.2) {
            self.collectionContext?.invalidateLayout(for: self)
        }
    }
}
