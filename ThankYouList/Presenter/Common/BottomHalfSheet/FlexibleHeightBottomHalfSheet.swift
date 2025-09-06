//
//  FlexibleHeightBottomHalfSheet.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/08/12.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

struct FlexibleHeightBottomHalfSheet<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: SheetContent

    @State private var sheetContentHeight = CGFloat(0)

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                sheetContent
                    .background {
                        //This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                        GeometryReader { proxy in
                            Color.clear
                                .task {
                                    sheetContentHeight = proxy.size.height
                                }
                        }
                    }
                    .presentationDetents([.height(sheetContentHeight)])
                    .presentationDragIndicator(.visible)
            }
    }
}

extension View {
    func flexibleHeightBottomHalfSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        sheetContent: SheetContent
    ) -> some View {
        self.modifier(FlexibleHeightBottomHalfSheet(
            isPresented: isPresented,
            sheetContent: sheetContent
        ))
    }
}
