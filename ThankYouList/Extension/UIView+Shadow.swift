//
//  UIView+Shadow.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/12/16.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func dropShadow() {
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowRadius = 2
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
}
