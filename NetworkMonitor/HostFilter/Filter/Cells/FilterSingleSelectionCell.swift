//
//  FilterSingleSelectionCell.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 3/30/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

private let segmentViewHeight: CGFloat = 36
private let titleLabelHeight: CGFloat = 16

private let noSegmentSelectedIndex: Int = -1

final class ReselectableSegmentedControl: UISegmentedControl {

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let previousSelectedSegmentIndex = selectedSegmentIndex
        super.touchesEnded(touches, with: event)
        if previousSelectedSegmentIndex == selectedSegmentIndex, let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if bounds.contains(touchLocation) {
                sendActions(for: .valueChanged)
            }
        }
    }
}

final class FilterSingleSelectionCell: ThemeableCollectionViewCell {

    private let titleLabel: ElementsLabel
    private let segmentView: ReselectableSegmentedControl
    private var currentSelectedIndex: Int = noSegmentSelectedIndex
    var segmentControlChangedIndex: ((Int) -> Void)?

    static let height: CGFloat = titleLabelHeight + 4 + segmentViewHeight + 8

    override init(frame: CGRect) {
        segmentView = ReselectableSegmentedControl(items: [])
        titleLabel = ElementsLabel()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCell(title: String, options: [ElementsFilterSelection], selectedItem: String?) {
        titleLabel.text = title
        segmentView.removeAllSegments()
        var selectedItemIndex: Int?
        for (i, option) in options.enumerated() {
            if option.keyID == selectedItem {
                selectedItemIndex = i
            }
            segmentView.insertSegment(withTitle: option.displayText, at: i, animated: false)
        }
        if selectedItem != nil, let index = selectedItemIndex {
            segmentView.selectedSegmentIndex = index
        }
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        titleLabel.font = theme.fonts.primaryTextFont
        titleLabel.textColor = theme.colors.primaryTextColorLightCanvas
        segmentView.setTitleTextAttributes(
            [NSAttributedString.Key.font: theme.fonts.largeTextFont], for: .normal
        )
        segmentView.tintColor = theme.colors.themeColor
        segmentView.backgroundColor = theme.colors.backgroundColor
    }
}

extension FilterSingleSelectionCell {

    private func setupUI() {
        setupTitleLabel()
        setupSegmentedControl()
        setupConstraints()
    }

    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
    }

    private func setupSegmentedControl() {
        addSubview(segmentView)
        segmentView.addTarget(self, action: #selector(toggleSwithed(_:)), for: .valueChanged)
    }

    private func setupConstraints() {
        let padding = ApplicationDependency.manager.theme.uiPaddingUnit
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(padding * 2)
            make.top.equalToSuperview().offset(4)
        }

        segmentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(padding * 2)
            make.height.equalTo(segmentViewHeight)
        }
    }
}

extension FilterSingleSelectionCell {

    @objc
    private func toggleSwithed(_ segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == currentSelectedIndex {
            segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
            segmentControlChangedIndex?(noSegmentSelectedIndex)
            currentSelectedIndex = noSegmentSelectedIndex
            return
        }
        currentSelectedIndex = segmentedControl.selectedSegmentIndex
        segmentControlChangedIndex?(segmentedControl.selectedSegmentIndex)
    }
}
