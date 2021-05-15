//
//  BaseSettingsViewController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/15/19.
//

import UIKit

class BaseSettingsViewController: BaseListViewController {

    let actionButtonContainer: UIView
    let actionButton: UIButton

    let actionButtonContainerHeight: CGFloat = 45 + 2 * 12
    let actionButtonHeight: CGFloat = 45

    override init() {
        self.actionButtonContainer = UIView()
        self.actionButton = UIButton()
        super.init()
        adapter.collectionView = collectionView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        actionButtonContainer.addShadow(
            size: CGSize(width: 0, height: 2),
            radius: 4,
            shadowColor: theme.colors.secondaryTextColorLightCanvas.withAlphaComponent(0.5),
            shadowOpacity: 0.5,
            viewCornerRadius: 0
        )
        var padding: CGFloat = 0
        if #available(iOS 11.0, *) {
            padding = view.safeAreaInsets.bottom
        }

        actionButtonContainer.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(actionButtonContainerHeight + padding)
        }

        actionButton.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(actionButtonHeight)
            make.top.equalToSuperview().offset(12)
        }
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: actionButtonContainerHeight + UIDevice.current.verticalPadding + 2 * theme.uiPaddingUnit, right: 0)
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        UIView.animate(withDuration: theme.themeChangeAnimDuration, delay: 0, options: [.curveEaseInOut], animations: {
            self.view.backgroundColor = theme.colors.darkCanvasBackgroundColor
            self.collectionView.backgroundColor = theme.colors.darkCanvasBackgroundColor
            self.actionButtonContainer.backgroundColor = theme.colors.backgroundColor
            self.actionButton.setTitleColor(theme.colors.primaryTextColorDarkCanvas, for: .normal)
            self.actionButton.backgroundColor = theme.colors.themeColor
        })
        actionButton.titleLabel?.font = theme.fonts.boldPrimaryTextFont
    }

    @objc func applyFilterButtonTapped() {
    }

    @objc func dismissButtonTapped() {
    }

    func setupUI() {
        setupCollectionView()
        setupActionButtons()
        setupConstraints()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = true
    }

    private func setupActionButtons() {
        view.addSubview(actionButtonContainer)
        actionButtonContainer.addSubview(actionButton)
        actionButton.contentHorizontalAlignment = .center
        actionButton.layer.cornerRadius = actionButtonHeight / 2
        actionButton.setTitle("Apply", for: .normal)
        actionButton.addTarget(self, action: #selector(applyFilterButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
