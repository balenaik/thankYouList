//
//  UIColor+Theme.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/10/03.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

extension UIColor {
    class var primary: UIColor {
        return UIColor(colorWithHexValue: 0xfcb5b5)
    }

    class var primary900: UIColor {
        return UIColor(colorWithHexValue: 0xfa8d8d)
    }

    class var materialGrey: UIColor {
        return UIColor(colorWithHexValue: 0x9e9e9e)
    }

    class var text: UIColor {
        return UIColor.black.withAlphaComponent(0.87)
    }

    class var sectionTitleGray: UIColor {
        return UIColor(white: 119.0 / 255.0, alpha: 1.0)
    }

    class var highGray: UIColor {
        return UIColor(colorWithHexValue: 0xc8c8c8)
    }

    class var highlightYellow: UIColor {
        return UIColor(colorWithHexValue: 0xfffc99)
    }
}
