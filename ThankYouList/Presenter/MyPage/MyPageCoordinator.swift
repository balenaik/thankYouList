//
//  MyPageCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/10.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

class MyPageCoordinator: Coordinator {

    var routingType: RoutingType
    weak var viewController: UIViewController?

    init(presentingViewController: UIViewController) {
        routingType = RoutingType.modal(presentingViewController: presentingViewController)
    }

    func start() {
        guard let viewController = R.storyboard.myPage.instantiateInitialViewController() else {
            return
        }
        viewController.router = self
        let navigationController = UINavigationController(rootViewController: viewController)
        self.viewController = navigationController
        navigationController.modalPresentationStyle = .pageSheet
        routingType.previousViewController?.present(navigationController, animated: true)
    }
}

extension MyPageCoordinator: MyPageRouter {
    func dismiss() {
        viewController?.dismiss(animated: true)
    }

    func switchToLogin() {
        guard let window = UIApplication.shared.windows.first(where: \.isKeyWindow) else {
            return
        }
        let loginCoordinator = LoginCoordinator(window: window)
        loginCoordinator.start()
    }

    func presentConfirmDeleteAccount() {
        guard let viewController = viewController else { return }
        let coordinator = ConfirmDeleteAccountCoordinator(presentingViewController: viewController)
        coordinator.start()
    }
}
