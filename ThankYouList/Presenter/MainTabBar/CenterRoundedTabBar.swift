//
//  CenterRoundedTabBar.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2021/09/27.
//  Copyright © 2021 Aika Yamada. All rights reserved.
//

import UIKit

private let tabBarBorderWidth = CGFloat(1)

private let centerButtonSize = CGFloat(50)
private let centerButtonMargin = CGFloat(4)

private let centerCornerRadius = CGFloat(9)

private let itemTitlePositionOffset = CGFloat(20)

class CenterRoundedTabBar: UITabBar {

    private var shapeLayer: CALayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCenterButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCenterButton()
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

private extension CenterRoundedTabBar {
    func setupCenterButton() {
        let centerButton = UIButton()
        centerButton.isUserInteractionEnabled = true
        centerButton.backgroundColor = .cyan
        centerButton.layer.cornerRadius = centerButtonSize / 2
        centerButton.addTarget(self, action: #selector(centerButtonAction(_:)), for: .touchUpInside)
        addSubview(centerButton)
        
        centerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            centerButton.centerYAnchor.constraint(equalTo: self.topAnchor, constant: centerCornerRadius),
            centerButton.widthAnchor.constraint(equalToConstant: centerButtonSize),
            centerButton.heightAnchor.constraint(equalToConstant: centerButtonSize)
        ])
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

    @objc func centerButtonAction(_ sender: UIButton) {
        print("centerbuttonTapped")
    }
}

private extension CGFloat {
    var degreesToRadians: CGFloat { return self * .pi / 180 }
}
