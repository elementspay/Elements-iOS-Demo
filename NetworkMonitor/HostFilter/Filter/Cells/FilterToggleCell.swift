//
//  FilterToggleCell.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 5/22/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

private let padding = ApplicationDependency.manager.theme.uiPaddingUnit

final class FilterToggleCell: ThemeableCollectionViewCell {

    private let itemLabel: ElementsLabel
    private let colorIndicator: UIView
    private let switchView: UISwitch

    var didSetSelectedState: ((Bool) -> Void)?

    static let height: CGFloat = 56

    override init(frame: CGRect) {
        itemLabel = ElementsLabel()
        colorIndicator = UIView()
        switchView = UISwitch()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCell(title: String, selected: Bool) {
        colorIndicator.isHidden = true
        itemLabel.text = title
        switchView.setOn(selected, animated: false)
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        backgroundColor = theme.colors.backgroundColor
        itemLabel.font = theme.fonts.primaryTextFont
        itemLabel.textColor = theme.colors.primaryTextColorLightCanvas
        switchView.onTintColor = theme.colors.themeColor
    }
}

extension FilterToggleCell {

    private func setupUI() {
        setupLabel()
        setupSwitch()
        setupConstraints()
    }

    private func setupLabel() {
        addSubview(itemLabel)
        itemLabel.textAlignment = .left
        itemLabel.numberOfLines = 1
        itemLabel.adjustsFontSizeToFitWidth = true
        itemLabel.minimumScaleFactor = 0.5
    }

    private func setupSwitch() {
        addSubview(switchView)
        switchView.addTarget(self, action: #selector(didChangeSwitchedState), for: .valueChanged)
    }

    private func setupConstraints() {
        switchView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-padding * 3)
            make.centerY.equalToSuperview()
        }

        itemLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(padding * 3)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(switchView.snp.leading).offset(-padding)
        }
    }
}

extension FilterToggleCell {

    @objc
    private func didChangeSwitchedState(_ sender: UISwitch) {
        didSetSelectedState?(sender.isOn)
    }
}
