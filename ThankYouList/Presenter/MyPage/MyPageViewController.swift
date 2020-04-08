//
//  MyPageViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/08.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class MyPageViewController: UIViewController {
    static func createViewController() -> UIViewController? {
        guard let viewController = R.storyboard.myPage().instantiateInitialViewController() else { return nil }
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
}
