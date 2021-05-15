//
//  NetworkStatisticsCollectionViewCell.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import IGListKit
import UIKit

final class NetworkStatisticsCollectionViewCell: ThemeableCollectionViewCell {

    lazy var collectionView: UICollectionView = {
        let layout = ListCollectionViewLayout(stickyHeaders: false, scrollDirection: .horizontal, topContentInset: 0, stretchToEdge: false)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.decelerationRate = UIScrollView.DecelerationRate.fast
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = true
        view.showsHorizontalScrollIndicator = false
        view.isScrollEnabled = true
        self.contentView.addSubview(view)
        return view
    }()

    private let separator = Separator.create()

    static let height: CGFloat = NetworkStatisticsCell.height + 20

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.8)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.frame
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        UIView.animate(withDuration: theme.themeChangeAnimDuration, delay: 0, options: [.curveEaseInOut], animations: {
            self.collectionView.backgroundColor = theme.colors.backgroundColor
            self.separator.backgroundColor = theme.colors.separatorColor
        })
    }
}
