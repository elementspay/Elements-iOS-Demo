//
//  NetworkMonitorHeaderView.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 9/10/19.
//

import UIKit

protocol NetworkMonitorHeaderViewDelegate: class {
    func autoCompleteRequests(searchTerm: String)
}

final class NetworkMonitorHeaderView: ThemeableView {

    struct Constants {
        let searchBarContainerHeight: CGFloat = 56

        func caclHeight() -> CGFloat {
            return 4 + searchBarContainerHeight
        }
    }

    private let searchBar: NetworkMonitorSearchBarView
    private let searchBarContainer: UIView
    private let constants = Constants()

    weak var delegate: NetworkMonitorHeaderViewDelegate?

    override init(frame: CGRect) {
        searchBar = NetworkMonitorSearchBarView()
        searchBarContainer = UIView()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.applySketchShadow(color: ApplicationDependency.manager.theme.colors.shadowColor)
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        UIView.animate(withDuration: theme.themeChangeAnimDuration, delay: 0, options: [.curveEaseInOut], animations: {
            self.backgroundColor = theme.colors.backgroundColor
            self.layer.applySketchShadow(color: theme.colors.shadowColor)
            self.searchBar.backgroundColor = theme.colors.primaryTextColorLightCanvas.withAlphaComponent(0.05)
            self.searchBar.layer.borderColor = theme.colors.primaryTextColorLightCanvas.withAlphaComponent(0.1).cgColor
            self.searchBarContainer.backgroundColor = theme.colors.backgroundColor
        })
    }
}

extension NetworkMonitorHeaderView {

    private func setupUI() {
        setupSearchBarContainer()
        setupSearchBarView()
        setupConstraints()
    }

    private func setupSearchBarView() {
        searchBarContainer.addSubview(searchBar)
        searchBar.layer.cornerRadius = 20
        searchBar.layer.borderWidth = 1
        searchBar.setupView(delegate: self)
    }

    private func setupSearchBarContainer() {
        addSubview(searchBarContainer)
    }

    private func setupConstraints() {
        let paddingUnit: CGFloat = ApplicationDependency.manager.theme.uiPaddingUnit

        searchBarContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(constants.searchBarContainerHeight)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(paddingUnit * 2)
            make.height.equalTo(paddingUnit * 5.0)
        }
    }
}

extension NetworkMonitorHeaderView: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string != "\n" else {
            return true
        }
        if let oldText = textField.text {
            var finalString = ""
            if !string.isEmpty {
                finalString = oldText + string
            } else if !oldText.isEmpty {
                finalString = String(oldText.dropLast())
            }
            delegate?.autoCompleteRequests(searchTerm: finalString)
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            delegate?.autoCompleteRequests(searchTerm: text)
        }
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        textField.resignFirstResponder()
        delegate?.autoCompleteRequests(searchTerm: "")
        return false
    }
}

extension CALayer {
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.1,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
