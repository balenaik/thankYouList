//
//  LoginCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/09.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

class LoginCoordinator: Coordinator {
    private let window: UIWindow
    private weak var navigationController: UINavigationController?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        guard let viewController = R.storyboard.login.instantiateInitialViewController() else {
            return
        }
        viewController.router = self
        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController = navigationController
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

extension LoginCoordinator: LoginRouter {
    func switchToMainTabBar() {
        let mainTabbarCoordinator = MainTabbarCoordinator(window: window)
        mainTabbarCoordinator.start()
    }
}
