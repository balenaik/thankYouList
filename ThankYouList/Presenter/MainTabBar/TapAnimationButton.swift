//
//  TapAnimationButton.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2021/10/01.
//  Copyright © 2021 Aika Yamada. All rights reserved.
//

import UIKit

protocol TapAnimationButtonDelegate: class {
    func tapAnimationButtonDidTapButton()
}

class TapAnimationButton: UIButton {

    var scaleDownAnimationDuration = 0.2
    var restoreOriginalScaleAnimationDuration = 0.1
    var scaleDownRatio = CGFloat(0.9)

    weak var delegate: TapAnimationButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let outerBounds = bounds
        let currentLocation = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        let isTouchInside = outerBounds.contains(currentLocation)
        let isPreviousTouchInside = outerBounds.contains(previousLocation)

        if isTouchInside {
            if isPreviousTouchInside {
                sendActions(for: .touchDragInside)
            } else {
                sendActions(for: .touchDragEnter)
            }
        } else {
            sendActions(for: .touchDragOutside)
            if isPreviousTouchInside {
                sendActions(for: .touchDragExit)
            }
        }
        return true
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let outerBounds = bounds
        let currentLocation = touch.location(in: self)
        let isTouchInside = outerBounds.contains(currentLocation)

        if isTouchInside {
            return sendActions(for: .touchUpInside)
        } else {
            return sendActions(for: .touchUpOutside)
        }
    }
}

// MARK: - Private
private extension TapAnimationButton {
    func setup() {
        addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        addTarget(self, action: #selector(touchDragOutside(_:)), for: .touchDragOutside)
    }

    @objc func touchUpInside(_ sender: UIButton) {
        restoreOriginalScaleAnimation()
        delegate?.tapAnimationButtonDidTapButton()
    }

    @objc func touchDown(_ sender: UIButton) {
        scaleDownAnimation()
    }

    @objc func touchDragOutside(_ sender: UIButton) {
        restoreOriginalScaleAnimation()
    }

    func scaleDownAnimation() {
        UIView.animate(withDuration: scaleDownAnimationDuration) {
            self.transform = CGAffineTransform(scaleX: self.scaleDownRatio, y: self.scaleDownRatio)
        }
    }

    func restoreOriginalScaleAnimation() {
        UIView.animate(withDuration: restoreOriginalScaleAnimationDuration) {
            self.transform = CGAffineTransform.identity
        }
    }
}
