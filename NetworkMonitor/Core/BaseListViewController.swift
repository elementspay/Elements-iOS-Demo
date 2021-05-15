//
//  BaseListViewController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 9/14/19.
//

import UIKit
import IGListKit

open class BaseListViewController: BaseViewController {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    let collectionView: UICollectionView
    var sectionData: [ListDiffable] = []

    override init() {
        self.collectionView = UICollectionView(
            frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()
        )
        super.init()
    }
}

extension BaseListViewController: UICollectionViewDelegate {

    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionHeader {
            view.layer.zPosition = -1
        }
    }
}
