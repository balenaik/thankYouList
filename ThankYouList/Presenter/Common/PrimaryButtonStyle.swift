//
//  PrimaryButtonStyle.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/07/14.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

private let fontSize = CGFloat(17)
private let cornerRadius = CGFloat(16)
private let disabledOpacity = CGFloat(0.38)
private let pressedOpacity = CGFloat(0.7)

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        let backgroundOpacity = isEnabled ?
        configuration.isPressed ? pressedOpacity : 1
        : disabledOpacity

        return configuration.label
           .font(.boldAvenir(ofSize: fontSize))
           .frame(maxWidth: .infinity)
           .padding(.all, ViewConst.spacing12)
           .foregroundColor(isEnabled ? .text : .text.opacity(disabledOpacity))
           .background(Color.primary500.opacity(backgroundOpacity))
           .cornerRadius(cornerRadius)
    }
}
