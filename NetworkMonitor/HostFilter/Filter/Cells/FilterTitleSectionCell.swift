//
//  FilterTitleSectionCell.swift
//  NetworkMonitor
//
//  Created by Jocelyn Zhang on 1/4/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

private let toolTipIndicatorSize: CGFloat = 22

final class FilterTitleSectionCell: ThemeableCollectionViewCell {

    private let titleLabel: ElementsLabel

    static let height: CGFloat = 50

    override init(frame: CGRect) {
        titleLabel = ElementsLabel()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCell(title: String) {
        titleLabel.text = title.uppercased()
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        backgroundColor = theme.colors.darkCanvasBackgroundColor
        titleLabel.textColor = theme.colors.secondaryTextColorLightCanvas
        titleLabel.font = theme.fonts.secondaryTextFont
    }
}

extension FilterTitleSectionCell {

    private func setupUI() {
        setupTitleLabel()
        setupContraints()
    }

    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.textAlignment = .left
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.numberOfLines = 1
    }

    private func setupContraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-6)
        }
    }
}
