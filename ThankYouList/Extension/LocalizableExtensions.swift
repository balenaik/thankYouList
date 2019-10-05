//
//  LocalizableExtensions.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/10/05.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

private protocol Localizable {
    var localizableKey: String? { get set }
}

extension UILabel: Localizable {
    @IBInspectable var localizableKey: String? {
        get { return nil }

        set(key) {
            text = key?.localized
        }
    }
}

extension UIButton: Localizable {
    @IBInspectable var localizableKey: String? {
        get { return nil }

        set(key) {
            setTitle(key?.localized, for: .normal)
        }
    }
}
