//
//  AddThankYouCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/14.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

class AddThankYouCoordinator: Coordinator {
    private weak var presentingViewController: UIViewController?
    private weak var navigationController: UINavigationController?

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }

    func start() {
        guard let viewController = R.storyboard.addThankYou.instantiateInitialViewController() else {
            return
        }
        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController = navigationController
        navigationController.modalPresentationStyle = .fullScreen
        presentingViewController?.present(navigationController, animated: true)
    }
}
