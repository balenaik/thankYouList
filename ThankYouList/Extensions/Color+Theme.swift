//
//  Color+Theme.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2022/12/31.
//  Copyright © 2022 Aika Yamada. All rights reserved.
//

import SwiftUI

extension Color {
    static var primary: Color {
        return Color(hex: 0xfcb5b5)
    }

    static var primary100: Color {
        return Color(hex: 0xfee9e9)
    }

    static var primary200: Color {
        return Color(hex: 0xfedada)
    }

    static var primary500: Color {
        return Color(hex: 0xfcb5b5)
    }

    static var primary900: Color {
        return Color(hex: 0xfa8d8d)
    }

    static var defaultBackground: Color {
        return Color(hex: 0xf5f5f5)
    }

    static var materialGrey: Color {
        return Color(hex: 0x9e9e9e)
    }

    static var highlight: Color {
        return Color(hex: 0xe1e1e1)
    }

    static var redAccent200: Color {
        return Color(hex: 0xff5252)
    }

    static var text: Color {
        return Color.black87
    }

    static var black87: Color {
        return Color.black.opacity(0.87)
    }

    static var black26: Color {
        return Color.black.opacity(0.26)
    }
}
