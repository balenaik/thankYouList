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

    class var primary200: UIColor {
        return UIColor(colorWithHexValue: 0xfedada)
    }

    class var primary500: UIColor {
        return UIColor(colorWithHexValue: 0xfcb5b5)
    }

    class var primary900: UIColor {
        return UIColor(colorWithHexValue: 0xfa8d8d)
    }

    class var defaultBackground: UIColor {
        return UIColor(colorWithHexValue: 0xf5f5f5)
    }

    class var materialGrey: UIColor {
        return UIColor(colorWithHexValue: 0x9e9e9e)
    }

    class var highlight: UIColor {
        return UIColor(colorWithHexValue: 0xe1e1e1)
    }

    class var redAccent200: UIColor {
        return UIColor(colorWithHexValue: 0xff5252)
    }

    class var text: UIColor {
        return UIColor.black87
    }

    class var black87: UIColor {
        return UIColor.black.withAlphaComponent(0.87)
    }

    class var black26: UIColor {
        return UIColor.black.withAlphaComponent(0.26)
    }
}
