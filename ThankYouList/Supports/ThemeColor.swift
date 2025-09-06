//
//  ThemeColor.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/03/24.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI
import UIKit

enum ThemeColor {
    case redAccent200
    case text

    var swiftUIColor: Color {
        switch self {
        case .redAccent200: return .redAccent200
        case .text: return .text
        }
    }

    var uiColor: UIColor {
        switch self {
        case .redAccent200: return .redAccent200
        case .text : return .text
        }
    }
}
