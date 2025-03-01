//
//  UIViewController+ViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2025/02/26.
//  Copyright © 2025 Aika Yamada. All rights reserved.
//

import UIKit

extension UIViewController {
    func getVisibleViewController() -> UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.getVisibleViewController()
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.getVisibleViewController()
        } else if let presentedViewController = self.presentedViewController {
            return presentedViewController.getVisibleViewController()
        } else {
            return self
        }
    }
}
