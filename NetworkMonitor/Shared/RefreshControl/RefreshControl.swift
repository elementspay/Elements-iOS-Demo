//
//  ElementsRefreshControl.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 1/6/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

private let limRefreshOffset: CGFloat = 64

enum ElementsRefreshState {
    // do nothing
    case normal
    // begin refresh
    case pulling
    // when pass offset, user release
    case willRefresh
}

final class ElementsRefreshControl: UIControl {

    private weak var scrollView: UIScrollView?
    private let refreshView: ElementsRefreshView

    public init() {
        refreshView = ElementsRefreshView()
        super.init(frame: CGRect.zero)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard let sv = newSuperview as? UIScrollView else {
            return
        }
        scrollView = sv
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
    }

    override func removeFromSuperview() {
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        super.removeFromSuperview()
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard let sv = scrollView else {
            return
        }
        let height = -(sv.contentInset.top + sv.contentOffset.y)
        if height < 0 {
            return
        }
        if sv.isDragging {
            if height > limRefreshOffset && refreshView.refreshState == .normal {
                refreshView.refreshState = .pulling
            } else if height <= limRefreshOffset && refreshView.refreshState == .pulling {
                refreshView.refreshState = .normal
            }
        } else {
            if refreshView.refreshState == .pulling {
                beginRefreshing()
                sendActions(for: .valueChanged)
            }
        }
    }

    func beginRefreshing() {
        guard let sv = scrollView else {
            return
        }
        if refreshView.refreshState == .willRefresh {
            return
        }
        refreshView.refreshState = .willRefresh
        var inset = sv.contentInset
        inset.top += limRefreshOffset
        UIView.animate(withDuration: 0.15) {
            sv.contentInset = inset
        }
    }

    func endRefreshing() {
        guard let sv = scrollView else {
            return
        }
        if refreshView.refreshState != .willRefresh {
            return
        }
        refreshView.refreshState = .normal
        var inset = sv.contentInset
        inset.top -= limRefreshOffset
        UIView.animate(withDuration: 0.15) {
            sv.contentInset = inset
        }
    }
}

extension ElementsRefreshControl {

    private func setupUI() {
        backgroundColor = superview?.backgroundColor
        addSubview(refreshView)
        refreshView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
