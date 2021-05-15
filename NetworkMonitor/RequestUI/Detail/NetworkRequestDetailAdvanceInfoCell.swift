//
//  NetworkRequestDetailAdvanceInfoCell.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

final class NetworkRequestDetailAdvanceInfoCell: ThemeableCollectionViewCell {

    struct Constants {
        static let height: CGFloat = 50
        let horizontalInset: CGFloat = 16
        let verticalInset: CGFloat = 12
        let checkMoreButtonWidth: CGFloat = 8
        let checkMoreButtonHeight: CGFloat = 14
    }

    private let titleLabel: ElementsLabel
    private let valueLabel: ElementsLabel
    private let checkMoreButton: UIButton
    private let separator: Separator

    private let constants = Constants()

    override init(frame: CGRect) {
        titleLabel = ElementsLabel()
        valueLabel = ElementsLabel()
        checkMoreButton = UIButton()
        separator = Separator.create()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCell(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        titleLabel.font = theme.fonts.primaryTextFont
        titleLabel.textColor = theme.colors.primaryTextColorLightCanvas
        valueLabel.font = theme.fonts.primaryTextFont
        valueLabel.textColor = theme.colors.secondaryTextColorLightCanvas
        checkMoreButton.setImage(theme.images.rightTriangleIcon, for: .normal)
        separator.backgroundColor = theme.colors.separatorColor
    }
}

extension NetworkRequestDetailAdvanceInfoCell {

    private func setupUI() {
        setupTitleLabel()
        setupValueLabel()
        setupCheckMoreButton()
        setupSeparator()
        setupConstraints()
    }

    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
    }

    private func setupValueLabel() {
        addSubview(valueLabel)
        valueLabel.textAlignment = .left
        valueLabel.numberOfLines = 1
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.5
    }

    private func setupCheckMoreButton() {
        addSubview(checkMoreButton)
        checkMoreButton.contentHorizontalAlignment = .center
        checkMoreButton.contentVerticalAlignment = .center
    }

    private func setupSeparator() {
        addSubview(separator)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(constants.horizontalInset)
            make.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(checkMoreButton.snp.leading).offset(-8)
            make.centerY.equalTo(titleLabel)
        }

        checkMoreButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(constants.checkMoreButtonWidth)
            make.height.equalTo(constants.checkMoreButtonHeight)
            make.trailing.equalToSuperview().offset(-constants.horizontalInset)
        }

        separator.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.8)
        }
    }
}
