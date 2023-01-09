//
//  MainTabbarCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/09.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

class MainTabbarCoordinator: Coordinator {

    let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        guard let mainTabbarController = R.storyboard.mainTabBar.instantiateInitialViewController() else {
            return
        }
        
        let thankYouListViewController = ThankYouListViewController.createViewController()
        let calendarViewController = CalendarViewController.createViewController()

        mainTabbarController.thankYouListNavigationController = thankYouListViewController as? UINavigationController
        mainTabbarController.calendarNavigationController = calendarViewController as? UINavigationController

        let tabs = [thankYouListViewController, calendarViewController].compactMap { $0 }
        mainTabbarController.setViewControllers(tabs, animated: false)

        window.rootViewController = mainTabbarController
        window.makeKeyAndVisible()
    }
}
