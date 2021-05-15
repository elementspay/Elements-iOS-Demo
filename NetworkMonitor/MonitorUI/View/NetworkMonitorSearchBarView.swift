//
//  NetworkMonitorSearchBarView.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 9/10/19.
//

import UIKit

private let searchImageViewSize: CGFloat = 20
private let inputTextFieldHeight: CGFloat = 24

final class NetworkMonitorSearchBarView: ThemeableView {

    let inputTextField: UITextField
    private let searchImageView: UIImageView

    override init(frame: CGRect) {
        inputTextField = UITextField()
        searchImageView = UIImageView()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView(delegate: UITextFieldDelegate) {
        inputTextField.delegate = delegate
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        UIView.animate(withDuration: theme.themeChangeAnimDuration, delay: 0, options: [.curveEaseInOut], animations: {
            self.inputTextField.font = theme.fonts.primaryTextFont
            self.inputTextField.textColor = theme.colors.primaryTextColorLightCanvas
            self.inputTextField.tintColor = theme.colors.themeColor
            self.searchImageView.image = theme.images.searchIcon
            self.inputTextField.attributedPlaceholder = NSAttributedString(
                string: "Search Request",
                attributes: [NSAttributedString.Key.foregroundColor: theme.colors.primaryTextColorLightCanvas]
            )
        })
    }
}

extension NetworkMonitorSearchBarView {

    private func setupUI() {
        setupTextField()
        setupImageView()
        setupConstraints()
    }

    private func setupTextField() {
        addSubview(inputTextField)
        inputTextField.placeholder = "Search"
        inputTextField.autocorrectionType = .no
        inputTextField.clearButtonMode = .whileEditing
        inputTextField.keyboardType = .asciiCapable
        inputTextField.autocapitalizationType = .none
    }

    private func setupImageView() {
        addSubview(searchImageView)
        searchImageView.contentMode = .scaleAspectFit
    }

    private func setupConstraints() {
        let paddingUnit: CGFloat = ApplicationDependency.manager.theme.uiPaddingUnit
        searchImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(paddingUnit * 2.5)
            make.width.height.equalTo(searchImageViewSize)
            make.centerY.equalToSuperview()
        }

        inputTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(searchImageView.snp.trailing).offset(paddingUnit * 1.5)
            make.trailing.equalToSuperview().inset(paddingUnit * 2.5)
            make.height.equalTo(inputTextFieldHeight)
        }
    }
}
