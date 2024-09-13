//
//  View+ScrollView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/09/13.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import SwiftUI

private let scrollView = "scrollView"

extension View {
    func offsetDetectableScrollView(offsetSubject: CurrentValueSubject<CGFloat, Never>) -> some View {
        ScrollView {
            self.background(GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: OffsetPreferenceKey.self,
                        value: -proxy.frame(in: .named(scrollView)).minY
                    )
            })
        }
        .coordinateSpace(name: scrollView)
        .onPreferenceChange(OffsetPreferenceKey.self) { offset in
            offsetSubject.send(offset)
        }
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {}
}
