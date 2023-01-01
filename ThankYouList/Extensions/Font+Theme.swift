//
//  Font+Theme.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/01.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import SwiftUI

extension Font {
    static func regularAvenir(ofSize size: CGFloat) -> Font {
        return .custom("Avenir-Book", size: size)
    }

    static func boldAvenir(ofSize size: CGFloat) -> Font {
        return .custom("Avenir-Heavy", size: size)
    }
}
