//
//  NetworkRequestDetailBasicInfoCell.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

final class NetworkRequestDetailBasicInfoCell: ThemeableCollectionViewCell {

    struct Constants {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 12
        static let verticalSpace: CGFloat = 4
        static let titleLabelHeight: CGFloat = 25
        static var valueLabelFont: UIFont = ApplicationDependency.manager.theme.fonts.primaryTextFont
    }

    private let titleLabel: ElementsLabel
    private let valueLabel: ElementsLabel
    private let separator: Separator

    private let constants = Constants()

    override init(frame: CGRect) {
        titleLabel = ElementsLabel()
        valueLabel = ElementsLabel()
        separator = Separator.create()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCell(title: String, value: String, valueColor: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = valueColor
    }

    static func calcHeight(containerWidth: CGFloat, text: String) -> CGFloat {
        let textHeight = HelperManager.textHeight(text, width: containerWidth - 2 * Constants.horizontalInset, font: Constants.valueLabelFont)
        return Constants.verticalInset + Constants.titleLabelHeight + Constants.verticalSpace + textHeight + 8
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        titleLabel.font = theme.fonts.primaryTextFont
        titleLabel.textColor = theme.colors.secondaryTextColorLightCanvas
        valueLabel.textColor = theme.colors.primaryTextColorLightCanvas
        separator.backgroundColor = theme.colors.separatorColor
        Constants.valueLabelFont = theme.fonts.primaryTextFont
        valueLabel.font = Constants.valueLabelFont
    }
}

extension NetworkRequestDetailBasicInfoCell {

    private func setupUI() {
        setupTitleLabel()
        setupValueLabel()
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
        valueLabel.numberOfLines = 0
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.5
    }

    private func setupSeparator() {
        addSubview(separator)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalInset)
            make.top.equalToSuperview().offset(Constants.verticalInset)
        }

        valueLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }

        separator.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.8)
        }
    }
}
