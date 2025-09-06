//
//  LottieView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/05/02.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    let filename: String

    func makeUIView(context: Context) -> some UIView {
        let animationView = LottieAnimationView(name: filename)
        animationView.play()
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false

        let view = UIView()
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
