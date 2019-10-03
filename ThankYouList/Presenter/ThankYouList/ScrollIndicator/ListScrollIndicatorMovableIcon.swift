//
//  ListScrollIndicatorMovableIcon.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/08/12.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

private let triangleColor = UIColor.sectionTitleGray

class ListScrollIndicatorMovableIcon: UIView {
    
    @IBOutlet weak var upperTriangleView: ListScrollIndicatorMovableIconTriangle!
    @IBOutlet weak var lowerTriangleView: ListScrollIndicatorMovableIconTriangle!
    
    class func instanceFromNib() -> ListScrollIndicatorMovableIcon {
        let view = Bundle.main.loadNibNamed("ListScrollIndicatorMovableIcon", owner: self, options: nil)?.first as! ListScrollIndicatorMovableIcon
        return view
    }

    override func awakeFromNib() {
        lowerTriangleView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
}

class ListScrollIndicatorMovableIconCircle: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.bounds.size.width / 2
    }
}

class ListScrollIndicatorMovableIconTriangle : UIView {
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()
        context.setFillColor(triangleColor.cgColor)
        context.fillPath()
    }
}
