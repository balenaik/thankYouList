//
//  AddThankYouCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/14.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

class AddThankYouCoordinator: Coordinator {

    var routingType: RoutingType
    weak var viewController: UIViewController?

    init(presentingViewController: UIViewController) {
        routingType = .modal(presentingViewController: presentingViewController)
    }

    func start() {
        guard let viewController = R.storyboard.addThankYou.instantiateInitialViewController() else {
            return
        }
        let navigationController = UINavigationController(rootViewController: viewController)
        self.viewController = navigationController
        navigationController.modalPresentationStyle = .fullScreen
        routingType.previousViewController?.present(navigationController, animated: true)
    }
}
