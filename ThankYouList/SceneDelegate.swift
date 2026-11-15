//
//  SceneDelegate.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2026/11/14.
//  Copyright © 2026 Aika Yamada. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let userRepository = DefaultUserRepository()
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let coordinator = AppCoordinator(window: window, userRepository: userRepository)
        appCoordinator = coordinator
        coordinator.start()

        if let url = connectionOptions.urlContexts.first?.url {
            try? coordinator.handleDeeplink(url: url)
        }
    }
}
