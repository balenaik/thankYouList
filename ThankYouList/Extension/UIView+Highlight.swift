//
//  UIView+Highlight.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/01/20.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func changeBgColorOnSettingView(isHighlighted: Bool) {
        UIView.animate(withDuration: 0.1, animations: {
            if isHighlighted {
                self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            } else {
                self.backgroundColor = UIColor.white
            }
        })
    }
}
