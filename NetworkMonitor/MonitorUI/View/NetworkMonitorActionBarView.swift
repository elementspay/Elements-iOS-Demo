//
//  NetworkMonitorActionBarView.swift
//  Alamofire
//
//  Created by Marvin Zhan on 9/11/19.
//

import UIKit

final class NetworkMonitorActionBarView: ThemeableView {

    struct Constants {
        let height: CGFloat = 46
        let horizontalOffset: CGFloat = 16
    }

    private let selectHostButton: UIButton
    private let sortButton: UIButton
    private let clearButton: UIButton
    private let separator: Separator
    private let constants = Constants()
    private var buttons: [UIButton] = []

    var selectHostAction: (() -> Void)?
    var sortAction: (() -> Void)?
    var clearAction: (() -> Void)?

    override init(frame: CGRect) {
        selectHostButton = UIButton()
        sortButton = UIButton()
        clearButton = UIButton()
        separator = Separator.create()
        buttons = [selectHostButton, sortButton, clearButton]
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        UIView.animate(withDuration: theme.themeChangeAnimDuration, delay: 0, options: [.curveEaseInOut], animations: {
            self.backgroundColor = theme.colors.backgroundColor
            self.separator.backgroundColor = theme.colors.separatorColor
            self.buttons.forEach { button in
                button.setTitleColor(theme.colors.themeColor, for: .normal)
                button.titleLabel?.font = theme.fonts.primaryTextFont
                button.backgroundColor = theme.colors.backgroundColor
            }
        })
    }
}

extension NetworkMonitorActionBarView {

    private func setupUI() {
        setupHostFilterButton()
        setupClearButton()
        setupSortButton()
        setupSeparator()
        setupConstraints()
    }

    private func setupButton(_ button: UIButton, title: String) {
        addSubview(button)
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = .center
    }

    private func setupSeparator() {
        addSubview(separator)
    }

    private func setupHostFilterButton() {
        setupButton(selectHostButton, title: "Filter")
        selectHostButton.addTarget(self, action: #selector(selectHostButtonTapped), for: .touchUpInside)
    }

    private func setupClearButton() {
        setupButton(clearButton, title: "Clear")
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
    }

    private func setupSortButton() {
        setupButton(sortButton, title: "Sort")
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        separator.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.8)
        }

        sortButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(constants.horizontalOffset)
            make.top.equalToSuperview()
            make.height.equalTo(constants.height)
        }

        clearButton.snp.makeConstraints { make in
            make.leading.equalTo(sortButton.snp.trailing).offset(constants.horizontalOffset)
            make.centerY.height.equalTo(sortButton)
        }

        selectHostButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-constants.horizontalOffset)
            make.top.height.equalTo(sortButton)
        }
    }
}

extension NetworkMonitorActionBarView {

    @objc
    private func selectHostButtonTapped() {
        selectHostAction?()
    }

    @objc
    private func sortButtonTapped() {
        sortAction?()
    }

    @objc
    private func clearButtonTapped() {
        clearAction?()
    }
}
