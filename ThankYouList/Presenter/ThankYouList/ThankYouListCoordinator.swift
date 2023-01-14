//
//  ThankYouListCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/09.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

class ThankYouListCoordinator: Coordinator {
    var routingType: RoutingType
    weak var viewController: UIViewController?

    init(navigationController: UINavigationController) {
        routingType = .push(navigationController: navigationController)
        viewController = navigationController
    }

    func start() {
        guard let viewController = R.storyboard.thankYouList.instantiateInitialViewController() else {
            return
        }
        viewController.router = self
        routingType.navigationController?.pushViewController(viewController, animated: false)
    }
}

extension ThankYouListCoordinator: ThankYouListRouter {
    func presentMyPage() {
        guard let viewController = viewController else { return }
        let coordinator = MyPageCoordinator(presentingViewController: viewController)
        coordinator.start()
    }
}
