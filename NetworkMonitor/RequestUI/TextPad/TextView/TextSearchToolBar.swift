//
//  TextSearchToolBar.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/14/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

public protocol TextSearchToolBarDelegate: class {
    func prevButtonTapped()
    func nextButtonTapped()
}

final class TextSearchToolBar: ThemeableView {

    struct Constants {
        public static let height: CGFloat = 40
        let horizontalInset: CGFloat = 16
        let buttonWidth: CGFloat = 70
        let textFont: UIFont = ApplicationDependency.manager.theme.fonts.boldPrimaryTextFont
    }

    private let topSeparator: Separator
    private let countLabel: ElementsLabel
    private let prevButton: UIButton
    private let nextButton: UIButton
    private var buttons: [UIButton] = []
    private let constants = Constants()

    weak var delegate: TextSearchToolBarDelegate?

    override init(frame: CGRect) {
        topSeparator = Separator.create()
        countLabel = ElementsLabel()
        prevButton = UIButton()
        nextButton = UIButton()
        buttons = [prevButton, nextButton]
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCountLabel(text: String) {
        countLabel.text = text
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        backgroundColor = theme.colors.backgroundColor.withAlphaComponent(0.9)
        topSeparator.backgroundColor = theme.colors.separatorColor
        countLabel.textColor = theme.colors.primaryTextColorLightCanvas
        buttons.forEach { button in
            button.setTitleColor(theme.colors.themeColor, for: .normal)
            button.backgroundColor = .clear
            button.titleLabel?.font = constants.textFont
        }
    }
}

extension TextSearchToolBar {

    private func setupUI() {
        setupSeparator()
        setupCountLabel()
        setupPrevButton()
        setupNextButton()
        setupConstraints()
    }

    private func setupSeparator() {
        addSubview(topSeparator)
    }

    private func setupCountLabel() {
        addSubview(countLabel)
        countLabel.font = constants.textFont
        countLabel.textAlignment = .left
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.5
        countLabel.numberOfLines = 1
    }

    private func setupPrevButton() {
        setupButton(prevButton)
        prevButton.setTitle("Previous", for: .normal)
        prevButton.addTarget(self, action: #selector(prevButtonTapped), for: .touchUpInside)
    }

    private func setupNextButton() {
        setupButton(nextButton)
        nextButton.setTitle("Next", for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }

    private func setupButton(_ button: UIButton) {
        addSubview(button)
        button.contentHorizontalAlignment = .center
    }

    private func setupConstraints() {
        topSeparator.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(0.8)
        }

        countLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(constants.horizontalInset)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(snp.centerX)
        }

        nextButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-constants.horizontalInset)
            make.height.equalToSuperview().inset(4)
            make.centerY.equalToSuperview()
            make.width.equalTo(constants.buttonWidth)
        }

        prevButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(nextButton.snp.leading).offset(-4)
            make.height.equalTo(nextButton)
            make.centerY.equalToSuperview()
            make.width.equalTo(constants.buttonWidth)
        }
    }
}

extension TextSearchToolBar {

    @objc
    private func prevButtonTapped() {
        delegate?.prevButtonTapped()
    }

    @objc
    private func nextButtonTapped() {
        delegate?.nextButtonTapped()
    }
}
