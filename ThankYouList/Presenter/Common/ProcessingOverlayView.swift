//
//  ProcessingOverlayView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/04/29.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

private let processingCircleJsonFilename = "processingCircle"
private let processingCircleSize = CGFloat(120)

private let presentingViewOverlayOpacity = CGFloat(0.6)

private struct ProcessingOverlayView<PresentingView: View>: View {

    @Binding var isProcessing: Bool
    let presentingView: PresentingView

    var body: some View {
        if isProcessing {
            ZStack {
                presentingView
                    .overlay(Color.white.opacity(presentingViewOverlayOpacity))

                LottieView(filename: processingCircleJsonFilename)
                    .frame(width: processingCircleSize, height: processingCircleSize)
            }
        } else {
            presentingView
        }
    }
}

extension View {
    func proccessingOverlay(isProcessing: Binding<Bool>) -> some View {
        ProcessingOverlayView(isProcessing: isProcessing, presentingView: self)
    }
}
