//
//  Animator.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/15/19.
//

import UIKit

protocol UIAnimator {
    var defaultDuration: TimeInterval { get }
}

extension UIAnimator {
    var defaultDuration: TimeInterval { return 0.25 }
}

final class RotationAnimatior: UIAnimator {

    static let defaultRotationKey = "rotationAnimation"

    func animateRotation(view: UIView,
                         animationKey: String = RotationAnimatior.defaultRotationKey,
                         repeatCount: Float = .infinity,
                         delayForRound: TimeInterval = 0.2,
                         durationForRound: TimeInterval = 2.2) {
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = durationForRound * 2 + delayForRound * 2
        animationGroup.repeatCount = repeatCount
        animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        let rotationPositive: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")

        rotationPositive.fromValue = 0
        rotationPositive.toValue = Double.pi * 4
        rotationPositive.duration = durationForRound
        rotationPositive.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        rotationPositive.autoreverses = false

        let rotationBack: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationBack.fromValue = Double.pi * 4
        rotationBack.toValue = 0
        rotationBack.duration = durationForRound
        rotationBack.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        rotationBack.autoreverses = false
        rotationBack.beginTime = durationForRound + delayForRound
        animationGroup.animations = [rotationPositive, rotationBack]
        view.layer.add(animationGroup, forKey: animationKey)
    }
}
