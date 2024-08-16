//
//  ConfirmDeleteAccountCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/15.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import SwiftUI

class ConfirmDeleteAccountCoordinator: Coordinator {
    var routingType: RoutingType
    weak var viewController: UIViewController?

    init(presentingViewController: UIViewController) {
        routingType = .modal(presentingViewController: presentingViewController)
    }

    func start() {
        let viewModel = ConfirmDeleteAccountViewModel(userRepository: DefaultUserRepository(),
                                                      analyticsManager: DefaultAnalyticsManager(),
                                                      router: self)
        let view = UIHostingController(
            rootView: ConfirmDeleteAccountView(viewModel: viewModel)
        )
        viewController = view
        routingType.previousViewController?.present(view, animated: true)
    }
}

extension ConfirmDeleteAccountCoordinator: ConfirmDeleteAccountRouter {
    func dismiss() {
        viewController?.dismiss(animated: true)
    }

    func switchToLogin() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        let loginCoordinator = LoginCoordinator(window: window)
        loginCoordinator.start()
    }
}
