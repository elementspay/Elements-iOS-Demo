//
//  ElementsRefreshView.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 1/6/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

final class ElementsRefreshView: ThemeableView {

    var refreshState: ElementsRefreshState = .normal {
        didSet {
            switch refreshState {
            case .normal:
                tipIcon.isHidden = false
                loadingImageView.isHidden = true
                loadingImageView.layer.removeAnimation(forKey: RotationAnimatior.defaultRotationKey)
                tipLabel.text = "Pull to refresh"
                UIView.animate(withDuration: 0.25) {
                    self.tipIcon.transform = CGAffineTransform.identity
                }
            case .pulling:
                tipLabel.text = "Release to refresh"
                UIView.animate(withDuration: 0.25) {
                    self.tipIcon.transform = CGAffineTransform(rotationAngle: CGFloat(.pi + 0.001))
                }
            case .willRefresh:
                loadingImageView.isHidden = false
                tipLabel.text = "Fetching data"
                tipIcon.isHidden = true
                RotationAnimatior().animateRotation(view: self.loadingImageView)
            }
        }
    }

    private let loadingImageView: UIImageView
    private let tipIcon: UIImageView
    private let tipLabel: ElementsLabel

    override init(frame: CGRect) {
        loadingImageView = UIImageView()
        tipIcon = UIImageView()
        tipLabel = ElementsLabel()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        loadingImageView.image = theme.images.loadingIcon
        tipIcon.image = theme.images.pullToRefreshIcon
        tipLabel.textColor = theme.colors.secondaryTextColorLightCanvas
        tipLabel.font = theme.fonts.primaryTextFont
    }
}

extension ElementsRefreshView {

    private func setupUI() {
        setupLoadingIndicator()
        setupTipLabel()
        setupTipIcon()
        setupConstraints()
    }

    private func setupLoadingIndicator() {
        addSubview(loadingImageView)
        loadingImageView.isHidden = true
        loadingImageView.contentMode = .scaleAspectFit
    }

    private func setupTipIcon() {
        addSubview(tipIcon)
        tipIcon.contentMode = .scaleAspectFit
    }

    private func setupTipLabel() {
        addSubview(tipLabel)
        tipLabel.text = "Pull to refresh"
        tipLabel.textAlignment = .center
        tipLabel.numberOfLines = 1
        tipLabel.minimumScaleFactor = 0.5
        tipLabel.adjustsFontSizeToFitWidth = true
    }

    private func setupConstraints() {
        loadingImageView.snp.makeConstraints { (make) in
            make.trailing.equalTo(tipLabel.snp.leading).offset(-8)
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
        }

        tipIcon.snp.makeConstraints { (make) in
            make.trailing.equalTo(tipLabel.snp.leading).offset(-4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }

        tipLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
