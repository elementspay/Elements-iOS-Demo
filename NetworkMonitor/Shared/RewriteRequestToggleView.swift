//
//  RewriteRequestToggleView.swift
//  Alamofire
//
//  Created by Marvin Zhan on 11/12/19.
//

import UIKit

public enum ElementsViewPresentingState {
    case hidden
    case presenting
    case dismissing
    case present
}

final class RewriteRequestToggleView: ThemeableView {

    struct Constants {
        let horizontalInset: CGFloat = 12
        let spaceBetweenTitleAndActionButton: CGFloat = 8
        let actionButtonWidth: CGFloat = 48
        let actionButtonHeight: CGFloat = 24
    }

    private let container: UIView
    private let titleLabel: ElementsLabel
    private let actionButton: UIButton
    private var action: (() -> Void)?

    private let constants = Constants()
    private let theme = ApplicationDependency.manager.theme

    var presentingState: ElementsViewPresentingState = .hidden

    override init(frame: CGRect) {
        container = UIView()
        titleLabel = ElementsLabel()
        actionButton = UIButton()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        addShadow(size: CGSize(width: 2, height: 2), radius: 8, shadowColor: theme.colors.secondaryTextColorLightCanvas.withAlphaComponent(0.3), shadowOpacity: 1, viewCornerRadius: 100)
        container.layer.cornerRadius = 10
        container.layer.borderWidth = 0.5
    }

    func setupView(title: String, actionButtonText: String, action: (() -> Void)?) {
        titleLabel.text = title
        actionButton.setTitle(actionButtonText, for: .normal)
        self.action = action
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        container.backgroundColor = theme.colors.backgroundColor
        container.layer.borderColor = theme.colors.lightTextColor.cgColor
        titleLabel.textColor = theme.colors.primaryTextColorLightCanvas
        titleLabel.font = theme.fonts.boldPrimaryTextFont
        actionButton.backgroundColor = theme.colors.errorColor
        actionButton.setTitleColor(theme.colors.primaryTextColorDarkCanvas, for: .normal)
        actionButton.titleLabel?.font = FontPlate.heavy10
    }
}

extension RewriteRequestToggleView {

    private func setupUI() {
        setupContainer()
        setupTitleLabel()
        setupActionButton()
        setupConstraints()
    }

    private func setupContainer() {
        addSubview(container)
        container.layer.masksToBounds = true
        container.clipsToBounds = true
    }

    private func setupTitleLabel() {
        container.addSubview(titleLabel)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
    }

    private func setupActionButton() {
        container.addSubview(actionButton)
        actionButton.contentHorizontalAlignment = .center
        actionButton.layer.cornerRadius = constants.actionButtonHeight / 2
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(constants.horizontalInset)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(actionButton.snp.leading).offset(
                -constants.spaceBetweenTitleAndActionButton
            )
        }

        actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-constants.horizontalInset)
            make.centerY.equalToSuperview()
            make.width.equalTo(constants.actionButtonWidth)
            make.height.equalTo(constants.actionButtonHeight)
        }
    }
}

extension RewriteRequestToggleView {

    @objc
    private func actionButtonTapped() {
        action?()
    }
}
