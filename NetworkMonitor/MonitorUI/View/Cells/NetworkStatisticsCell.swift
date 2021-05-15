//
//  NetworkStatisticsCell.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

final class NetworkStatisticsCell: ThemeableCollectionViewCell {

    private let titleLabel: ElementsLabel
    private let valueLabel: ElementsLabel

    static let height: CGFloat = 100

    override init(frame: CGRect) {
        titleLabel = ElementsLabel()
        valueLabel = ElementsLabel()
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
        UIView.animate(withDuration: theme.themeChangeAnimDuration, delay: 0, options: [.curveEaseInOut], animations: {
            self.backgroundColor = theme.colors.backgroundColor
            self.titleLabel.font = theme.fonts.largeTextFont
            self.titleLabel.textColor = theme.colors.primaryTextColorLightCanvas
            self.valueLabel.font = theme.fonts.largeTextFont
            self.valueLabel.textColor = theme.colors.primaryTextColorLightCanvas
        })
    }
}

extension NetworkStatisticsCell {

    private func setupUI() {
        setupTitleLabel()
        setupValueLabel()
        setupConstraints()
    }

    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
    }

    private func setupValueLabel() {
        addSubview(valueLabel)
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 1
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.5
    }

    private func setupConstraints() {
        let paddingUnit: CGFloat = ApplicationDependency.manager.theme.uiPaddingUnit
        titleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(valueLabel)
            make.top.equalTo(snp.centerY)
            make.bottom.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(paddingUnit / 2)
            make.top.equalToSuperview().offset(paddingUnit / 2)
            make.bottom.equalTo(snp.centerY)
        }
    }
}
