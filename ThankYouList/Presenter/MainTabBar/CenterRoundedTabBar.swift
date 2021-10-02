//
//  CenterRoundedTabBar.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2021/09/27.
//  Copyright © 2021 Aika Yamada. All rights reserved.
//

import UIKit

private let tabBarBorderWidth = CGFloat(1)
private let tabBarBorderColor = UIColor.black.withAlphaComponent(0.1)
private let tabBarBackgroundColor = UIColor.white

private let centerButtonSize = CGFloat(50)
private let centerButtonMargin = CGFloat(8)
private let centerButtonColor = UIColor.primary
private let centerButtonShadowOffset = CGSize(width: 0, height: 1)
private let centerButtonShadowColor = UIColor.black
private let centerButtonShadowOpacity = Float(0.2)
private let centerButtonShadowRadius = CGFloat(1)

private let centerCornerRadius = CGFloat(9)

private let itemTitlePositionOffset = CGFloat(20)

protocol CenterRoundedTabBarDelegate: class {
    func centerRoundedTabBarDidTapCenterButton()
}

class CenterRoundedTabBar: UITabBar {

    private var shapeLayer: CALayer?

    weak var customDelegate: CenterRoundedTabBarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        adjustItemTitlePosition()
    }

    override func draw(_ rect: CGRect) {
        setupShape()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        for subview in subviews {
            let subviewPoint = subview.convert(point, from: self)
            guard let result = subview.hitTest(subviewPoint, with: event) else { continue }
            return result
        }
        return nil
    }
}

// MARK: - Private
private extension CenterRoundedTabBar {
    func setup() {
        setupCenterButton()
        setupTransparentBackground()

        tintColor = .primary900
        unselectedItemTintColor = UIColor.black.withAlphaComponent(0.6)
    }

    func setupCenterButton() {
        let centerButton = TapAnimationButton()
        centerButton.delegate = self
        centerButton.isUserInteractionEnabled = true
        centerButton.setImage(R.image.icAdd36(), for: .normal)
        centerButton.tintColor = .white
        centerButton.backgroundColor = centerButtonColor
        centerButton.layer.cornerRadius = centerButtonSize / 2
        centerButton.layer.shadowOffset = centerButtonShadowOffset
        centerButton.layer.shadowColor = centerButtonShadowColor.cgColor
        centerButton.layer.shadowOpacity = centerButtonShadowOpacity
        centerButton.layer.shadowRadius = centerButtonShadowRadius
        centerButton.adjustsImageWhenHighlighted = false

        addSubview(centerButton)
        
        centerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            centerButton.centerYAnchor.constraint(equalTo: self.topAnchor, constant: centerCornerRadius),
            centerButton.widthAnchor.constraint(equalToConstant: centerButtonSize),
            centerButton.heightAnchor.constraint(equalToConstant: centerButtonSize)
        ])
    }

    func setupTransparentBackground() {
        backgroundImage = UIImage()
        shadowImage = UIImage()
        backgroundColor = .clear
    }

    func adjustItemTitlePosition() {
        // Supports only when item count is 2
        guard items?.count == 2 else { return }
        if let item1 = items?.getSafely(at: 0) {
            item1.titlePositionAdjustment = UIOffset(horizontal: -itemTitlePositionOffset, vertical: 0)
        }
        if let item2 = items?.getSafely(at: 1) {
            item2.titlePositionAdjustment = UIOffset(horizontal: itemTitlePositionOffset, vertical: 0)
        }
    }

    func setupShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.lineWidth = tabBarBorderWidth
        shapeLayer.fillColor = tabBarBackgroundColor.cgColor
        shapeLayer.strokeColor = tabBarBorderColor.cgColor

        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }

        self.shapeLayer = shapeLayer
    }

    func createPath() -> CGPath {
        let path = UIBezierPath()
        let centerX = self.frame.width / 2
        let roundRadius = centerButtonSize / 2 + centerButtonMargin

        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: centerX - roundRadius - centerCornerRadius, y: 0))
        path.addQuadCurve(to: CGPoint(x: centerX - roundRadius, y: centerCornerRadius),
                          controlPoint: CGPoint(x: centerX - roundRadius, y: 0))
        path.addArc(withCenter: CGPoint(x: centerX, y: centerCornerRadius),
                    radius: roundRadius,
                    startAngle: CGFloat(180).degreesToRadians,
                    endAngle: CGFloat.zero.degreesToRadians,
                    clockwise: false)
        path.addQuadCurve(to: CGPoint(x: centerX + roundRadius + centerCornerRadius, y: 0),
                          controlPoint: CGPoint(x: centerX + roundRadius, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.close()
        return path.cgPath
    }
}

private extension CGFloat {
    var degreesToRadians: CGFloat { return self * .pi / 180 }
}

extension CenterRoundedTabBar: TapAnimationButtonDelegate {
    func tapAnimationButtonDidTapButton() {
        customDelegate?.centerRoundedTabBarDidTapCenterButton()
    }
}
