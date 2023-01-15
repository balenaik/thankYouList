//
//  MainTabbarCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/09.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

class MainTabbarCoordinator: Coordinator {

    private let window: UIWindow
    var routingType: RoutingType
    weak var viewController: UIViewController?

    init(window: UIWindow) {
        self.window = window
        routingType = .none
    }

    func start() {
        guard let mainTabbarController = R.storyboard.mainTabBar.instantiateInitialViewController() else {
            return
        }
        mainTabbarController.router = self
        self.viewController = mainTabbarController

        let thankYouListNavController = UINavigationController()
        let thankYouListCoordinator = ThankYouListCoordinator(navigationController: thankYouListNavController)
        thankYouListCoordinator.start()

        let calendarNavController = UINavigationController()
        let calendarCoordinator = CalendarCoordinator(navigationController: calendarNavController)
        calendarCoordinator.start()

        mainTabbarController.thankYouListNavigationController = thankYouListNavController
        mainTabbarController.calendarNavigationController = calendarNavController

        mainTabbarController.setViewControllers(
            [thankYouListNavController, calendarNavController],
            animated: false)

        window.rootViewController = mainTabbarController
        window.makeKeyAndVisible()
    }
}

extension MainTabbarCoordinator: MainTabBarRouter {
    func presentAddThankYou() {
        guard let viewController = viewController else { return }
        let coordinator = AddThankYouCoordinator(
            presentingViewController: viewController)
        coordinator.start()
    }
}
