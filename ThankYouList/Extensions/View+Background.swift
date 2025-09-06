//
//  View+Background.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/02/15.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

extension View {
    func screenBackground<Background: View>(_ background: Background) -> some View {
        ZStack {
            background.ignoresSafeArea()
            self
        }
    }

    func listBackgroundForIOS16AndAbove<Background: View>(_ background: Background) -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden)
                .background(background)
        } else {
            return self
        }
    }
}
