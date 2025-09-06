//
//  Color+Blend.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/07/14.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

extension Color {
    static func createBlendedColor(base: Color, with blending: Color, blendingOpacity: CGFloat) -> Color {
        let baseUIColor = UIColor(base)
        let blendUIColor = UIColor(blending).withAlphaComponent(blendingOpacity)

        var baseRed = CGFloat(0)
        var baseGreen = CGFloat(0)
        var baseBlue = CGFloat(0)
        var baseAlpha = CGFloat(0)

        var blendRed = CGFloat(0)
        var blendGreen = CGFloat(0)
        var blendBlue = CGFloat(0)
        var blendAlpha = CGFloat(0)

        baseUIColor.getRed(&baseRed, green: &baseGreen, blue: &baseBlue, alpha: &baseAlpha)
        blendUIColor.getRed(&blendRed, green: &blendGreen, blue: &blendBlue, alpha: &blendAlpha)

        return Color(
            red: baseRed * (1 - blendAlpha) + blendRed * blendAlpha,
            green: baseGreen * (1 - blendAlpha) + blendGreen * blendAlpha,
            blue: baseBlue * (1 - blendAlpha) + blendBlue * blendAlpha
        )
    }
}
