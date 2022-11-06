//
//  LoginContinueButton.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2021/09/22.
//  Copyright © 2021 Aika Yamada. All rights reserved.
//

import UIKit

private let normalBackgroundColor = UIColor.white
private let highlightedBackgroundColor = UIColor.materialGrey.withAlphaComponent(0.2)
private let highlightDuration = 0.3

private let buttonBorderWidth = CGFloat(0.5)
private let buttonBorderColor = UIColor.black.cgColor
private let buttonCornerRadius = CGFloat(24)

private let imageLeftInset = CGFloat(20)

class LoginContinueButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: highlightDuration) {
                self.backgroundColor = self.isHighlighted
                    ? highlightedBackgroundColor : normalBackgroundColor
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()

    }

    private func setup() {
        layer.cornerRadius = buttonCornerRadius
        layer.borderWidth = buttonBorderWidth
        layer.borderColor = buttonBorderColor
        titleLabel?.font = UIFont.boldAvenir(ofSize: 15)

        adjustsImageWhenHighlighted = false

        adjustInset()
    }

    private func adjustInset() {
        let originalImageEdgeInsets = self.imageEdgeInsets
        let originalTitleEdgeInsets = self.titleEdgeInsets
        let buttonWidth = self.frame.width
        let imageWidth = self.imageView?.frame.width ?? 0
        let textWidth = self.titleLabel?.frame.width ?? 0

        self.imageEdgeInsets = UIEdgeInsets(top: originalImageEdgeInsets.top,
                                            left: imageLeftInset,
                                            bottom: originalImageEdgeInsets.bottom,
                                            right: buttonWidth - textWidth - imageWidth)
        self.titleEdgeInsets = UIEdgeInsets(top: originalTitleEdgeInsets.top,
                                            left: -imageWidth / 2,
                                            bottom: originalTitleEdgeInsets.bottom,
                                            right: 0)
    }
}
