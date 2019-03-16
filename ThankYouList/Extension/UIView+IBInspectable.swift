//
//  UIView+IBInspectable.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/03/10.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable
    var borderColor: UIColor? {
        get {
            guard let borderColor = self.layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: borderColor)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
}
