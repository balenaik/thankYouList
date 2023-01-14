//
//  MyPageCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/10.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

class MyPageCoordinator: Coordinator {
    private weak var presentingNavigationController: UINavigationController?
    private weak var navigationController: UINavigationController?

    init(presentingNavigationController: UINavigationController) {
        self.presentingNavigationController = presentingNavigationController
    }

    func start() {
        guard let viewController = R.storyboard.myPage.instantiateInitialViewController() else {
            return
        }
        viewController.router = self
        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController = navigationController
        navigationController.modalPresentationStyle = .pageSheet
        presentingNavigationController?.present(navigationController, animated: true)
    }
}

extension MyPageCoordinator: MyPageRouter {
    func dismiss() {
        navigationController?.dismiss(animated: true)
    }

    func switchToLogin() {
        guard let window = UIApplication.shared.windows.first(where: \.isKeyWindow) else {
            return
        }
        let loginCoordinator = LoginCoordinator(window: window)
        loginCoordinator.start()
    }
}
