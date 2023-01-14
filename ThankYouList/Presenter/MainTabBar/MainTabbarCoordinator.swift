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
    private weak var mainTabbarController: MainTabBarController?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        guard let mainTabbarController = R.storyboard.mainTabBar.instantiateInitialViewController() else {
            return
        }
        self.mainTabbarController = mainTabbarController

        let thankYouListNavController = UINavigationController()
        let thankYouListCoordinator = ThankYouListCoordinator(navigationController: thankYouListNavController)
        thankYouListCoordinator.start()

        let calendarViewController = CalendarViewController.createViewController()

        mainTabbarController.thankYouListNavigationController = thankYouListNavController
        mainTabbarController.calendarNavigationController = calendarViewController as? UINavigationController

        let tabs = [thankYouListNavController, calendarViewController].compactMap { $0 }
        mainTabbarController.setViewControllers(tabs, animated: false)

        window.rootViewController = mainTabbarController
        window.makeKeyAndVisible()
    }
}
