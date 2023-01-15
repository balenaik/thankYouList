//
//  CalendarCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/15.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

class CalendarCoordinator: Coordinator {
    var routingType: RoutingType
    weak var viewController: UIViewController?

    init(navigationController: UINavigationController) {
        routingType = .push(navigationController: navigationController)
        viewController = navigationController
    }

    func start() {
        guard let viewController = R.storyboard.calendar.instantiateInitialViewController() else {
            return
        }
        routingType.navigationController?.pushViewController(viewController, animated: false)
    }
}
