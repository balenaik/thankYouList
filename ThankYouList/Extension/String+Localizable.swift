//
//  String+Localizable.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/10/05.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation

private protocol Localizable {
    var localized: String { get }
}

extension String: Localizable {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
