//
//  ThankYouListCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/09.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

class ThankYouListCoordinator: Coordinator {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        guard let viewController = R.storyboard.thankYouList.instantiateInitialViewController() else {
            return
        }
        viewController.router = self
        navigationController?.pushViewController(viewController, animated: false)
    }
}

extension ThankYouListCoordinator: ThankYouListRouter {
    func presentMyPage() {
        guard let navigationController = navigationController else { return }
        let coordinator = MyPageCoordinator(presentingNavigationController: navigationController)
        coordinator.start()
    }
}
