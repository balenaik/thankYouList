//
//  EditThankYouCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/15.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

class EditThankYouCoordinator: Coordinator {

    var routingType: RoutingType
    weak var viewController: UIViewController?
    private let thankYouId: String

    init(thankYouId: String, presentingViewController: UIViewController) {
        self.thankYouId = thankYouId
        routingType = .modal(presentingViewController: presentingViewController)
    }

    func start() {
        guard let viewController = R.storyboard.editThankYou.instantiateInitialViewController() else {
            return
        }
        viewController.editingThankYouId = thankYouId
        let navigationController = UINavigationController(rootViewController: viewController)
        self.viewController = navigationController
        navigationController.modalPresentationStyle = .fullScreen
        routingType.previousViewController?.present(navigationController, animated: true)
    }
}
