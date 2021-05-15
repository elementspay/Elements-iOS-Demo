//
//  TextPadViewController.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/12/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

protocol TextPadViewControllerDelegate: class {
    func dismiss()
}

open class TextPadViewController: BaseViewController {

    struct Constants {
        let verticalInset: CGFloat = 16
        let horizontalInset: CGFloat = 12
        let searchFieldHeight: CGFloat = 40
        let rewriteIndicatorViewHeight: CGFloat = 40
    }

    private let interactor: TextPadInteractor
    private let searchTextField: ElementsTextField
    private let topContainer: UIView
    private let textView: ElementsTextView
    private let toolBar: TextSearchToolBar
    private let rewriteIndicatorView: RewriteRequestToggleView

    private let lexer = JSONLexer()
    private let constants = Constants()

    weak var delegate: TextPadViewControllerDelegate?

    public init(interactor: TextPadInteractor) {
        self.interactor = interactor
        self.searchTextField = ElementsTextField(leftEdge: 16)
        self.topContainer = UIView()
        self.textView = ElementsTextView()
        self.toolBar = TextSearchToolBar()
        self.rewriteIndicatorView = RewriteRequestToggleView()
        super.init()
    }

    required convenience public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        addKeyboardNotifications()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        interactor.applyRewrite()
    }

    deinit {
        interactor.applyRewrite()
        removeKeyboardNotifications()
    }

    private func loadData() {
        interactor.loadData()
    }

    override func apply(theme: ElementsTheme) {
        super.apply(theme: theme)
        let rightBarButton = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(exportButtonTapped))
        rightBarButton.setTitleTextAttributes([NSAttributedString.Key.font: theme.fonts.primaryTextFont], for: .normal)
        navigationItem.setRightBarButtonItems([rightBarButton], animated: false)
        view.backgroundColor = theme.colors.backgroundColor
        textView.textColor = theme.colors.textPadColor
        textView.backgroundColor = theme.colors.backgroundColor
        textView.tintColor = theme.colors.themeColor
        textView.font = theme.fonts.secondaryTextFont
        textView.keyboardAppearance = theme == .light ? .light : .dark
        topContainer.backgroundColor = theme.colors.backgroundColor

        searchTextField.keyboardAppearance = theme == .light ? .light : .dark
        searchTextField.backgroundColor = theme.colors.lightBackgroundColor
        searchTextField.tintColor = theme.colors.themeColor
        searchTextField.font = theme.fonts.primaryTextFont
        searchTextField.textColor = theme.colors.primaryTextColorLightCanvas
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search Keyword",
            attributes: [NSAttributedString.Key.foregroundColor: theme.colors.secondaryTextColorLightCanvas]
        )
        searchTextField.layer.borderColor = theme.colors.primaryTextColorLightCanvas.withAlphaComponent(0.1).cgColor
    }

    override open func adjustViewWhenKeyboardShow(notification: NSNotification) {
        guard let info = obtainKeyboardInfo(from: notification) else { return }
        var bottomInset: CGFloat = info.keyboardHeight
        if #available(iOS 11.0, *) {
            bottomInset -= view.safeAreaInsets.bottom
        }
        bottomInset += TextSearchToolBar.Constants.height
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        textView.scrollIndicatorInsets = textView.contentInset
        toolBar.isHidden = false
        toolBar.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview().offset(-info.keyboardHeight)
        }
        UIView.animate(withDuration: info.duration, delay: 0, options: info.option, animations: {
            self.view.layoutIfNeeded()
        })
    }

    override open func adjustViewWhenKeyboardDismiss(notification: NSNotification) {
        guard let info = obtainKeyboardInfo(from: notification) else { return }
        textView.contentInset = UIEdgeInsets.zero
        textView.scrollIndicatorInsets = textView.contentInset
        toolBar.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview().offset(TextSearchToolBar.Constants.height)
        }
        UIView.animate(withDuration: info.duration, delay: 0, options: info.option, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.toolBar.isHidden = true
        }
    }
}

extension TextPadViewController {

    private func setupUI() {
        navigationItem.title = "Body"
        setupTextView()
        setupRewriteToggleView()
        setupTopContainer()
        setupSearchTextField()
        setupToolBar()
        setupConstraints()
    }

    private func setupTopContainer() {
        view.addSubview(topContainer)
    }

    private func setupRewriteToggleView() {
        view.addSubview(rewriteIndicatorView)
        rewriteIndicatorView.isHidden = true
        rewriteIndicatorView.setupView(title: "Overriding Request.", actionButtonText: "RESET") { [weak self] in
            self?.interactor.handleResetRequest()
        }
    }

    private func setupTextView() {
        view.addSubview(textView)
        textView.isUserInteractionEnabled = true
        textView.isEditable = ApplicationSettings.enabledRewrite
        textView.sourceDelegate = self
    }

    private func setupSearchTextField() {
        topContainer.addSubview(searchTextField)
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.autocorrectionType = .no
        searchTextField.autocapitalizationType = .none
        searchTextField.layer.cornerRadius = 20
        searchTextField.placeholder = "Search JSON"
        searchTextField.layer.borderWidth = 1
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    private func setupToolBar() {
        view.addSubview(toolBar)
        toolBar.isHidden = true
        toolBar.setupCountLabel(text: "0 Result")
        toolBar.delegate = self
    }

    private func setupConstraints() {
        topContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(constants.searchFieldHeight + constants.verticalInset)
        }

        searchTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(constants.verticalInset)
            make.leading.trailing.equalToSuperview().inset(constants.horizontalInset)
            make.height.equalTo(constants.searchFieldHeight)
        }

        rewriteIndicatorView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(
                -constants.rewriteIndicatorViewHeight - constants.verticalInset
            )
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(constants.rewriteIndicatorViewHeight)
        }

        textView.snp.makeConstraints { (make) in
            make.top.equalTo(rewriteIndicatorView.snp.bottom).offset(constants.verticalInset)
            make.leading.trailing.bottom.equalToSuperview().inset(4)
        }

        toolBar.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(TextSearchToolBar.Constants.height)
            make.bottom.equalToSuperview().offset(TextSearchToolBar.Constants.height)
        }
    }

    private func convertRange(range: NSRange, forTextView textView: UITextView) -> UITextRange? {
        let beginning = textView.beginningOfDocument
        guard let start = textView.position(from: beginning, offset: range.location),
            let end = textView.position(from: start, offset: range.length) else {
            return nil
        }
        return textView.textRange(from: start, to: end)
    }
}

extension TextPadViewController: TextSearchToolBarDelegate {

    private func updateResultCount() {
        guard let numberOfMatches = textView.numberOfMatches(), numberOfMatches > 0 else {
            toolBar.setupCountLabel(text: "0 Result")
            return
        }
        let matchedIndex = (textView.indexOfMatchedString() ?? 0) + 1
        toolBar.setupCountLabel(text: String(format: "%@ / %@ Result", String(matchedIndex), String(numberOfMatches)))
    }

    public func prevButtonTapped() {
        interactor.handleSearchPrevTerm()
    }

    public func nextButtonTapped() {
        interactor.handleSearchNextTerm()
    }
}

extension TextPadViewController: TextPadPresenterOutput {

    func showPresentationData(displayText: NSAttributedString) {
        textView.attributedText = displayText
    }

    func showAlertController(alert: UIViewController) {
        present(alert, animated: true, completion: nil)
    }

    func showFirstSearchOccurance(range: NSRange) {
        textView.scrollRangeToVisible(range: range, consideringInsets: true)
    }

    func showNextMatch(term: String) {
        showMatchWith(term: term, direction: .forward)
    }

    func showPrevMatch(term: String) {
        showMatchWith(term: term, direction: .backward)
    }

    func showDisplayText(displayText: String) {
        textView.theme = DefaultSourceCodeTheme()
        textView.text = displayText
        textView.setText(displayText)
    }

    func showMatchWith(term: String, direction: TextViewSearchDirection) {
        if term.isEmpty {
            textView.resetSearch()
        } else {
            textView.scrollToString(target: term, searchDirection: direction)
        }
        updateResultCount()
    }

    func showRewriteToggleView(animated: Bool) {
        guard rewriteIndicatorView.presentingState == .hidden else { return }
        rewriteIndicatorView.snp.updateConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(constants.verticalInset)
        }
        rewriteIndicatorView.presentingState = .presenting
        rewriteIndicatorView.isHidden = false
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.rewriteIndicatorView.presentingState = .present
            })
        } else {
            self.rewriteIndicatorView.presentingState = .present
        }
    }

    func hideRewriteToggleView(animated: Bool) {
        guard rewriteIndicatorView.presentingState == .present else { return }
        rewriteIndicatorView.snp.updateConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(
                -constants.rewriteIndicatorViewHeight - constants.verticalInset
            )
        }
        rewriteIndicatorView.presentingState = .dismissing
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.rewriteIndicatorView.isHidden = true
                self.rewriteIndicatorView.presentingState = .hidden
            })
        } else {
            self.rewriteIndicatorView.isHidden = true
            self.rewriteIndicatorView.presentingState = .hidden
        }
    }
}

extension TextPadViewController {

    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        guard let text = searchTextField.text else {
            return
        }
        interactor.searchTerm(text)
    }

    @objc
    private func dismissButtonTapped() {
        delegate?.dismiss()
    }

    @objc
    private func exportButtonTapped() {
        interactor.handleExportButtonTapped()
    }
}

extension TextPadViewController: TextViewSourceDelegate {
    public func textViewDidBeginEditing(_ syntaxTextView: ElementsTextView) {
        searchTextField.endEditing(true)
        toolBar.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview().offset(TextSearchToolBar.Constants.height)
        }
    }

    public func didChangeText(_ syntaxTextView: ElementsTextView) {
        textView.setText(textView.text)
        interactor.handleTextOverride(text: textView.text)
    }

    public func didChangeSelectedRange(_ syntaxTextView: ElementsTextView, selectedRange: NSRange) {
    }

    public func lexerForSource(_ source: String) -> Lexer {
        return lexer
    }
}
