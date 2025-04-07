//
//  View+Background.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2025/04/06.
//  Copyright © 2025 Aika Yamada. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func widgetBackground(color: Color) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(color, for: .widget)
        } else {
            self.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(color)
        }
    }
}
