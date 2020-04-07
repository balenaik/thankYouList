//
//  BalloonView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/08/12.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class BalloonView: UIView {
    
    let triangleSideLength: CGFloat = 20
    let triangleHeight: CGFloat = 17.3
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 30
        self.backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
            
        contextBalloonPath(rect: rect)
    }

    func contextBalloonPath(rect: CGRect) {
        let triangleRightCorner = CGPoint(x: (rect.size.width + triangleSideLength) / 2, y: rect.maxY - triangleHeight)
        let triangleBottomCorner = CGPoint(x: rect.size.width / 2, y: rect.maxY)
        let triangleLeftCorner = CGPoint(x: (rect.size.width - triangleSideLength) / 2, y: rect.maxY - triangleHeight)

        TYLColor.pinkColor.setStroke()
        TYLColor.pinkColor.setFill()
        let path = UIBezierPath(roundedRect: CGRect(x:  rect.minX,y: rect.minY, width: rect.width, height: rect.height - triangleHeight), cornerRadius: 10)
        path.stroke()
        path.move(to: triangleLeftCorner)
        path.addLine(to: triangleBottomCorner)
        path.addLine(to: triangleRightCorner)
        path.fill()
    }
    
}
