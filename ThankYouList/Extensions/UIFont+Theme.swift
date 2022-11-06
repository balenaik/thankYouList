//
//  UIFont+Theme.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2021/10/05.
//  Copyright © 2021 Aika Yamada. All rights reserved.
//

import UIKit

extension UIFont {
    class func regularAvenir(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Avenir-Book", size: size)!
    }

    class func boldAvenir(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Avenir-Heavy", size: size)!
    }
}
