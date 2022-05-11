//
//  UIColor+Modification.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2022/05/12.
//  Copyright © 2022 Aika Yamada. All rights reserved.
//

import UIKit

extension UIColor {
    func lighten(addingValue: CGFloat = 0.1) -> UIColor {
        return addColor(addingValue: addingValue)
    }

    func darken(addingValue: CGFloat = 0.1) -> UIColor {
        return addColor(addingValue: -1 * addingValue)
    }
}

private extension UIColor {
    func addColor(addingValue: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )

        return UIColor(
            red: addValue(addingValue, originalValue: red),
            green: addValue(addingValue, originalValue: green),
            blue: addValue(addingValue, originalValue: blue),
            alpha: alpha
        )
    }

    func addValue(_ value: CGFloat, originalValue: CGFloat) -> CGFloat {
        return max(0, min(1, originalValue + value))
    }
}
