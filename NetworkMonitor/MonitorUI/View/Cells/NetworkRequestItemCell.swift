//
//  NetworkRequestItemCell.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

private let theme = ApplicationDependency.manager.theme

final class NetworkRequestItemCell: ThemeableCollectionViewCell {

    struct Constants {
        static let height: CGFloat = 80
        let statusLabelWidth: CGFloat = 60
        let statusLabelHeight: CGFloat = 40
        let horizontalInset: CGFloat = 20
        let verticalInset: CGFloat = 20
        let checkMoreButtonWidth: CGFloat = 10
        let checkMoreButtonHeight: CGFloat = 18
        let methodLabelWidth: CGFloat = 40
    }

    private let statusLabel: ElementsLabel
    private let methodLabel: ElementsLabel
    private let pathLabel: ElementsLabel
    private let timeLabel: ElementsLabel
    private let responseTimeLabel: ElementsLabel
    private let checkMore: UIButton
    private let separator: Separator
    private let overrideIndicator: ElementsLabel

    private var labels: [ElementsLabel] = []
    private let constants: Constants = Constants()

    override init(frame: CGRect) {
        statusLabel = ElementsLabel()
        methodLabel = ElementsLabel()
        pathLabel = ElementsLabel()
        timeLabel = ElementsLabel()
        responseTimeLabel = ElementsLabel()
        checkMore = UIButton()
        overrideIndicator = ElementsLabel()
        separator = Separator.create()
        labels = [statusLabel, methodLabel, pathLabel, timeLabel, responseTimeLabel, overrideIndicator]
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        statusLabel.layer.cornerRadius = 4
        statusLabel.layer.masksToBounds = true
    }

    func setupCell(model: NetworkRequestDisplayModel) {
        statusLabel.text = model.status
        statusLabel.textColor = model.statusColor
        methodLabel.text = model.method
        pathLabel.text = model.path
        timeLabel.text = model.time + " ᐧ "
        responseTimeLabel.text = model.responseTime
        responseTimeLabel.textColor = model.responseTimeColor
        overrideIndicator.isHidden = !model.isOverrided
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        UIView.animate(withDuration: theme.themeChangeAnimDuration, delay: 0, options: [.curveEaseInOut], animations: {
            self.separator.backgroundColor = theme.colors.separatorColor
            self.statusLabel.backgroundColor = theme.colors.lightBackgroundColor
            self.statusLabel.textColor = theme.colors.themeColor
            self.timeLabel.textColor = theme.colors.lightTextColor
            self.methodLabel.textColor = theme.colors.primaryTextColorLightCanvas
            self.pathLabel.textColor = theme.colors.primaryTextColorLightCanvas
            self.overrideIndicator.textColor = theme.colors.lightTextColor
        })
        methodLabel.font = theme.fonts.boldPrimaryTextFont
        pathLabel.font = theme.fonts.primaryTextFont
        statusLabel.font = theme.fonts.boldPrimaryTextFont
        responseTimeLabel.font = theme.fonts.secondaryTextFont
        overrideIndicator.font = theme.fonts.secondaryTextFont
        checkMore.setImage(theme.images.rightTriangleIcon, for: .normal)
        timeLabel.font = theme.fonts.secondaryTextFont
    }
}

extension NetworkRequestItemCell {

    private func setupUI() {
        setupLabels()
        setupCheckMoreButton()
        setupSeparator()
        setupConstraints()
    }

    private func setupSeparator() {
        addSubview(separator)
    }

    private func setupLabels() {
        setupStatusLabel()
        setupMethodLabel()
        setupPathLabel()
        setupTimeLabel()
        setupResponseTimeLabel()
        setupOverrideLabel()

        for label in labels {
            label.adjustsFontSizeToFitWidth = true
            label.numberOfLines = 1
            label.minimumScaleFactor = 0.8
        }
    }

    private func setupStatusLabel() {
        addSubview(statusLabel)
        statusLabel.textAlignment = .center
    }

    private func setupMethodLabel() {
        addSubview(methodLabel)
        methodLabel.textAlignment = .left
    }

    private func setupPathLabel() {
        addSubview(pathLabel)
        pathLabel.textAlignment = .left
    }

    private func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabel.textAlignment = .left
    }

    private func setupResponseTimeLabel() {
        addSubview(responseTimeLabel)
        responseTimeLabel.textAlignment = .left
    }

    private func setupOverrideLabel() {
        addSubview(overrideIndicator)
        overrideIndicator.textAlignment = .left
        overrideIndicator.text = " ᐧ Overriding"
    }

    private func setupCheckMoreButton() {
        addSubview(checkMore)
        checkMore.contentHorizontalAlignment = .center
        checkMore.contentVerticalAlignment = .center
    }

    private func setupConstraints() {
        statusLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(constants.horizontalInset)
            make.top.equalToSuperview().offset(constants.verticalInset)
            make.width.equalTo(constants.statusLabelWidth)
            make.height.equalTo(constants.statusLabelHeight)
        }

        methodLabel.snp.makeConstraints { (make) in
            make.top.equalTo(statusLabel)
            make.leading.equalTo(statusLabel.snp.trailing).offset(constants.horizontalInset)
            make.width.equalTo(constants.methodLabelWidth)
        }

        pathLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(methodLabel.snp.trailing).offset(2)
            make.centerY.equalTo(methodLabel)
            make.trailing.equalTo(checkMore.snp.leading).offset(-2)
        }

        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(methodLabel.snp.bottom).offset(4)
            make.leading.equalTo(methodLabel)
        }

        responseTimeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(timeLabel.snp.trailing)
            make.centerY.equalTo(timeLabel)
        }

        overrideIndicator.snp.makeConstraints { make in
            make.leading.equalTo(responseTimeLabel.snp.trailing)
            make.centerY.equalTo(timeLabel)
        }

        checkMore.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(constants.checkMoreButtonWidth)
            make.height.equalTo(constants.checkMoreButtonHeight)
            make.trailing.equalToSuperview().offset(-constants.horizontalInset)
        }

        separator.snp.makeConstraints { (make) in
            make.leading.equalTo(statusLabel)
            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.8)
        }
    }
}
