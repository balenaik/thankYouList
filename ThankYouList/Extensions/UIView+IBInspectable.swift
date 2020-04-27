//
//  UIView+IBInspectable.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/25.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }

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
