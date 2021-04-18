//
//  UIButton+BackgroundColor.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2021/01/07.
//  Copyright © 2021 Aika Yamada. All rights reserved.
//

import UIKit

extension UIButton {
    /// Set background color on the selected state
    /// - parameter color: background color
    /// - parameter for: state
    func setBackgroundColor(color: UIColor, for state: UIControl.State) {
        setBackgroundImage(UIImage.createImage(color: color), for: state)
    }
}

