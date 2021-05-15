//
//  MainEntryViewController.swift
//
//
//  Created by Marvin Zhan on 12/17/19.
//

import UIKit

private let entryViewSize: CGFloat = 60

public final class NetworkMonitorEntryView: UIView {

    private let entryView: UIView
    private let entryButton: UIButton

    var handleEntryButtonAction: (() -> Void)?

    override public init(frame: CGRect) {
        entryView = UIView()
        entryButton = UIButton()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        entryView.isHidden = false
        entryView.addShadow(
            size: CGSize(width: 0, height: 2),
            radius: 10,
            shadowColor: ColorPlate.darkGray.withAlphaComponent(0.1),
            shadowOpacity: 0.5,
            viewCornerRadius: 0
        )
    }

    private func setupUI() {
        setupEntryView()
        setupConstraints()
    }

    private func setupEntryView() {
        addSubview(entryView)
        entryView.addSubview(entryButton)
        entryView.backgroundColor = ColorPlate.darkestGray
        entryView.layer.cornerRadius = entryViewSize / 2
        entryView.alpha = 0.8

        entryButton.backgroundColor = .clear
        entryButton.setImage(ImageResources.logoCircleWhite, for: .normal)
        entryButton.layer.cornerRadius = entryViewSize / 2
        entryButton.addTarget(self, action: #selector(entryButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        entryView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        entryButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }

    @objc
    private func entryButtonTapped() {
        handleEntryButtonAction?()
    }
}

final class MainEntryViewController: UIViewController {

    private let entryView: NetworkMonitorEntryView
    private let coordinator = NetworkMonitorCoordinator()
    private var isPresenting: Bool = false

    init() {
        entryView = NetworkMonitorEntryView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height / 3, width: entryViewSize, height: entryViewSize))
        super.init(nibName: nil, bundle: nil)
        coordinator.start()
        coordinator.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        entryView.handleEntryButtonAction = {
            guard !self.isPresenting else { return }
            var topController: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
            while topController?.presentedViewController != nil {
                topController = topController?.presentedViewController
            }
            let controller = self.coordinator.toPresentable()
					controller.view.isUserInteractionEnabled = true
            self.entryView.isHidden = false
            self.coordinator.reset()
					topController?.present(controller, animated: true, completion: {
                self.isPresenting = true
            })
        }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        entryView.addGestureRecognizer(pan)
    }

    func shouldReceive(point: CGPoint) -> Bool {
        return entryView.frame.contains(point)
    }
}

extension MainEntryViewController {

    private func setupUI() {
        view.addSubview(entryView)
    }
}

extension MainEntryViewController {

    @objc
    private func panAction(_ panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .began {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.entryView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }, completion: nil)
        }

        let offset = panGesture.translation(in: view)
        panGesture.setTranslation(CGPoint.zero, in: view)
        var center = entryView.center
        center.x += offset.x
        center.y += offset.y
        entryView.center = center

        if panGesture.state == .ended || panGesture.state == .cancelled {
            let location = panGesture.location(in: view)
            let velocity = panGesture.velocity(in: view)
            var finalX: Double = 30
            var finalY: Double = Double(location.y)

            if location.x > UIScreen.main.bounds.size.width / 2 {
                finalX = Double(UIScreen.main.bounds.size.width) - 30.0
            }
            let horizentalVelocity = abs(velocity.x)
            let positionX = abs(finalX - Double(location.x))

            let velocityForce = sqrt(pow(velocity.x, 2) * pow(velocity.y, 2))

            let durationAnimation = (velocityForce > 1000.0) ? min(0.25, positionX / Double(horizentalVelocity)) : 0.25

            if velocityForce > 1000.0 {
                finalY += Double(velocity.y) * durationAnimation
            }

            if finalY > Double(UIScreen.main.bounds.size.height) - 50 {
                finalY = Double(UIScreen.main.bounds.size.height) - 50
            } else if finalY < 50 {
                finalY = 50
            }
            UIView.animate(withDuration: durationAnimation * 5,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 6,
                           options: .allowUserInteraction,
                           animations: {
                            self.entryView.center = CGPoint(x: finalX, y: finalY)
                            self.entryView.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
}

extension MainEntryViewController: NetworkMonitorMainWindowDelegate {

    func shouldHandle(point: CGPoint) -> Bool {
        return entryView.frame.contains(point)
    }
}

extension MainEntryViewController: NetworkMonitorCoordinatorDelegate {

    public func didDismiss(in coordinator: NetworkMonitorCoordinator) {
        guard entryView.isHidden else { return }
        entryView.isHidden = false
        entryView.alpha = 0
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
            self.entryView.alpha = 0.9
        }) { _ in
            self.isPresenting = false
        }
    }
}
