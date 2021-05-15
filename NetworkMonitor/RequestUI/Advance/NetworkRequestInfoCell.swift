//
//  NetworkRequestInfoCell.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

protocol NetworkRequestInfoCellDelegate: class {
    func cellHeightDidChange()
    func textViewEndEditing(text: String, tag: Int)
}

final class NetworkRequestInfoCell: ThemeableCollectionViewCell {

    struct Constants {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 12
        static let verticalSpace: CGFloat = 4
        static let titleLabelHeight: CGFloat = 25
        static let separatorHeight: CGFloat = 0.8
        static let resetButtonWidth: CGFloat = 52
        static let resetButtonHeight: CGFloat = 24
        static var valueLabelFont: UIFont = ApplicationDependency.manager.theme.fonts.primaryTextFont
        static var titleLabelFont: UIFont = ApplicationDependency.manager.theme.fonts.primaryTextFont
    }

    private let titleTextView: GrowingTextView
    private let valueTextView: GrowingTextView
    private let resetButton: UIButton
    private let separator: Separator

    var resetAction: (() -> Void)?
    weak var delegate: NetworkRequestInfoCellDelegate?

    override init(frame: CGRect) {
        titleTextView = GrowingTextView()
        valueTextView = GrowingTextView()
        resetButton = UIButton()
        separator = Separator.create()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func calcHeight(containerWidth: CGFloat,
                           title: String,
                           value: String,
                           resetState: Bool) -> CGFloat {
        let resetStateEdgeSpace = resetState ? Constants.resetButtonWidth + Constants.horizontalInset : 0
        let labelWidth = containerWidth - 2 * Constants.horizontalInset - resetStateEdgeSpace
        let titleHeight = HelperManager.textHeight(title, width: labelWidth, font: Constants.valueLabelFont)
        let valueHeight = HelperManager.textHeight(value, width: labelWidth, font: Constants.valueLabelFont)
        return Constants.verticalInset + Constants.verticalSpace + titleHeight + 8 + valueHeight
    }

    func setupCell(title: String, value: String, showResetButton: Bool) {
        titleTextView.text = title
        valueTextView.text = value
        updateResetButtonState(enabled: showResetButton)
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        titleTextView.font = theme.fonts.primaryTextFont
        titleTextView.backgroundColor = .clear
        titleTextView.textColor = theme.colors.secondaryTextColorLightCanvas
        valueTextView.textColor = theme.colors.primaryTextColorLightCanvas
        valueTextView.backgroundColor = .clear
        Constants.valueLabelFont = theme.fonts.primaryTextFont
        valueTextView.font = Constants.valueLabelFont
        separator.backgroundColor = theme.colors.separatorColor

        titleTextView.keyboardAppearance = theme == .light ? .light : .dark
        titleTextView.tintColor = theme.colors.themeColor
        valueTextView.keyboardAppearance = theme == .light ? .light : .dark
        valueTextView.tintColor = theme.colors.themeColor

        resetButton.backgroundColor = theme.colors.errorColor
        resetButton.setTitleColor(theme.colors.primaryTextColorDarkCanvas, for: .normal)
        resetButton.titleLabel?.font = theme.fonts.secondaryTextFont
    }

    func updateTextColor(titleColor: UIColor, valueColor: UIColor) {
        titleTextView.textColor = titleColor
        valueTextView.textColor = valueColor
    }

    func updateResetButtonState(enabled: Bool) {
        resetButton.isHidden = !enabled
        titleTextView.snp.remakeConstraints { make in
            if enabled {
                make.trailing.equalTo(resetButton.snp.leading).offset(-Constants.horizontalInset)
            } else {
                make.trailing.equalToSuperview().offset(-Constants.horizontalInset)
            }
            make.leading.equalToSuperview().offset(Constants.horizontalInset)
            make.top.equalToSuperview().offset(Constants.verticalInset)
        }
    }
}

extension NetworkRequestInfoCell {

    private func setupUI() {
        setupTitleLabel()
        setupValueLabel()
        setupResetButton()
        setupSeparator()
        setupConstraints()
    }

    private func setupTitleLabel() {
        addSubview(titleTextView)
        titleTextView.textAlignment = .left
        titleTextView.textContainerInset = .zero
        titleTextView.tag = 0
        titleTextView.isEditable = ApplicationSettings.enabledRewrite
        titleTextView.delegate = self
    }

    private func setupValueLabel() {
        addSubview(valueTextView)
        valueTextView.textAlignment = .left
        valueTextView.textContainerInset = .zero
        valueTextView.tag = 1
        titleTextView.isEditable = ApplicationSettings.enabledRewrite
        valueTextView.delegate = self
    }

    private func setupResetButton() {
        addSubview(resetButton)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.contentHorizontalAlignment = .center
        resetButton.layer.cornerRadius = 8
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }

    private func setupSeparator() {
        addSubview(separator)
    }

    private func setupConstraints() {
        titleTextView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalInset)
            make.top.equalToSuperview().offset(Constants.verticalInset)
        }

        valueTextView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(titleTextView)
            make.top.equalTo(titleTextView.snp.bottom).offset(Constants.verticalSpace)
        }

        resetButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-Constants.horizontalInset)
            make.width.equalTo(Constants.resetButtonWidth)
            make.height.equalTo(Constants.resetButtonHeight)
        }

        separator.snp.makeConstraints { (make) in
            make.leading.equalTo(titleTextView)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(Constants.separatorHeight)
        }
    }
}

extension NetworkRequestInfoCell: GrowingTextViewDelegate {

    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        delegate?.cellHeightDidChange()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewEndEditing(
            text: textView.text,
            tag: textView.tag
        )
    }
}

extension NetworkRequestInfoCell {

    @objc
    private func resetButtonTapped() {
        resetAction?()
    }
}
