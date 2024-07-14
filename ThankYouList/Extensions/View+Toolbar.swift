//
//  View+Toolbar.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/04/06.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI
import Combine

extension View {
    func cancelButtonToolbar(_ buttonTapAction: @escaping () -> Void) -> some View {
        self.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: buttonTapAction) {
                    Image(R.image.icClose24)
                        .foregroundColor(.text)
                }
            }
        }
    }
}
