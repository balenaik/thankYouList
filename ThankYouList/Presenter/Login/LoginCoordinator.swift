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
    var routingType: RoutingType
    weak var viewController: UIViewController?

    init(window: UIWindow) {
        self.window = window
        routingType = .none
    }

    func start() {
        guard let viewController = R.storyboard.login.instantiateInitialViewController() else {
            return
        }
        viewController.router = self
        let navigationController = UINavigationController(rootViewController: viewController)
        self.viewController = navigationController
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
