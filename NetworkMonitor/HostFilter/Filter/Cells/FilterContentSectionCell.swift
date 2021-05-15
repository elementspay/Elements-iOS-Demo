//
//  FilterSectionCell.swift
//  NetworkMonitor
//
//  Created by Jocelyn Zhang on 1/3/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import SnapKit
import UIKit

final class FilterContentSectionCell: ThemeableCollectionViewCell {

    private let checkBox: UIImageView
    private let containerView: UIView
    private let titleLabel: ElementsLabel

    private var isFirstCell: Bool = false
    private var isLastCell: Bool = false

    static let customizedBorder: String = "customizedBorder"
    static let height: CGFloat = 48
    static let largeCellHeight: CGFloat = 56

    private var isCellSelected: Bool = false

    override init(frame: CGRect) {
        containerView = UIView()
        checkBox = UIImageView(image: ApplicationDependency.manager.theme.images.checkMarkIcon)
        titleLabel = ElementsLabel()
        super.init(frame: frame)
        setupUI()
    }

    override func prepareForReuse() {
        checkBox.isHidden = true
        isFirstCell = false
        isLastCell = false
        if let layers = layer.sublayers {
            for layer in layers {
                if layer.name == FilterContentSectionCell.customizedBorder {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCell(option: ElementsFilterSelection,
                   selected: Bool,
                   isFirstCell: Bool = false,
                   isLastCell: Bool = false) {
        titleLabel.text = option.displayText
        self.isCellSelected = selected
        selected ? selectCell() : deselectCell()
        if isFirstCell {
            layer.addBorder(edge: .top, color: ColorPlate.black.withAlphaComponent(0.12), thickness: 0.5)
            self.isFirstCell = isFirstCell
            self.isLastCell = false
        } else if isLastCell {
            layer.addBorder(edge: .bottom, color: ColorPlate.black.withAlphaComponent(0.12), thickness: 0.5)
            self.isLastCell = isLastCell
            self.isFirstCell = false
        }
        setupContraints()
        setNeedsLayout()
    }

    func selectCell() {
        containerView.backgroundColor = ApplicationDependency.manager.theme.colors.themeColor.withAlphaComponent(0.05)
        checkBox.isHidden = false
        titleLabel.textColor = ApplicationDependency.manager.theme.colors.themeColor
    }

    func deselectCell() {
        containerView.backgroundColor = ApplicationDependency.manager.theme.colors.backgroundColor
        checkBox.isHidden = true
        titleLabel.textColor = ApplicationDependency.manager.theme.colors.primaryTextColorLightCanvas
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        containerView.backgroundColor = theme.colors.backgroundColor
        backgroundColor = theme.colors.backgroundColor
        titleLabel.textColor = theme.colors.primaryTextColorLightCanvas
        titleLabel.font = theme.fonts.primaryTextFont
        isCellSelected ? selectCell() : deselectCell()
        containerView.backgroundColor = isSelected ? theme.colors.themeColor.withAlphaComponent(0.05) : theme.colors.backgroundColor
    }
}

extension FilterContentSectionCell {

    private func setupUI() {
        setupTitleLabel()
        setupImageView()
        setupContainerView()
    }

    private func setupTitleLabel() {
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.numberOfLines = 1
        containerView.addSubview(titleLabel)
    }

    private func setupImageView() {
        checkBox.contentMode = .scaleAspectFit
        checkBox.isHidden = isSelected ? false : true
        containerView.addSubview(checkBox)
    }

    private func setupContainerView() {
        addSubview(containerView)
    }

    private func setupContraints() {
        let padding: CGFloat = 16.0
        containerView.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(padding / 2.0)
            make.height.equalTo(FilterContentSectionCell.height)
            make.top.equalToSuperview().offset(isFirstCell ? padding / 2.0 : 0.0)
        }

        titleLabel.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(padding)
            make.height.equalTo(FilterContentSectionCell.height)
            make.centerY.equalToSuperview()
        }

        checkBox.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().offset(-padding)
            make.height.width.equalTo(padding)
            make.centerY.equalToSuperview()
        }
    }
}

extension CALayer {
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case UIRectEdge.right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        border.backgroundColor = color.cgColor
        border.name = FilterContentSectionCell.customizedBorder
        addSublayer(border)
    }
}
