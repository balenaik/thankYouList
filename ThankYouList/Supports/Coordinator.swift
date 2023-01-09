//
//  Coordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/09.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

protocol Coordinator {
    func start()
}

class AppCoordinator: Coordinator {
    let window: UIWindow
    let userRepository: UserRepository

    init(window: UIWindow,
         userRepository: UserRepository) {
        self.window = window
        self.userRepository = userRepository
    }

    func start() {
        if userRepository.isLoggedIn() {
            let mainTabbarCoordinator = MainTabbarCoordinator(window: window)
            mainTabbarCoordinator.start()
        } else {
            let loginCoordinator = LoginCoordinator(window: window)
            loginCoordinator.start()
        }

        window.makeKeyAndVisible()
    }
}
