//
//  Color+Theme.swift
//  SharedResources
//
//  Created by Aika Yamada on 2022/12/31.
//  Copyright © 2022 Aika Yamada. All rights reserved.
//

import SwiftUI

extension Color {
    public static var primary: Color {
        return Color(hex: 0xfcb5b5)
    }

    public static var primary100: Color {
        return Color(hex: 0xfee9e9)
    }

    public static var primary200: Color {
        return Color(hex: 0xfedada)
    }

    public static var primary500: Color {
        return Color(hex: 0xfcb5b5)
    }

    public static var primary900: Color {
        return Color(hex: 0xfa8d8d)
    }

    public static var defaultBackground: Color {
        return Color(hex: 0xf5f5f5)
    }

    public static var materialGrey: Color {
        return Color(hex: 0x9e9e9e)
    }

    public static var highlight: Color {
        return Color(hex: 0xe1e1e1)
    }

    public static var redAccent200: Color {
        return Color(hex: 0xff5252)
    }

    public static var text: Color {
        return Color.black87
    }

    public static var black87: Color {
        return Color.black.opacity(0.87)
    }

    public static var black45: Color {
        return Color.black.opacity(0.45)
    }

    public static var black26: Color {
        return Color.black.opacity(0.26)
    }
}

private extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
