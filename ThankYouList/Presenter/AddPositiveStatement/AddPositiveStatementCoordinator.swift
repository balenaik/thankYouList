//
//  AddPositiveStatementCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/02/09.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

class AddPositiveStatementCoordinator: Coordinator {
    var routingType: RoutingType
    weak var viewController: UIViewController?

    init(presentingViewController: UIViewController) {
        routingType = .modal(presentingViewController: presentingViewController)
    }

    func start() {
        let view = UIHostingController(
            rootView: AddPositiveStatementView()
        )
        viewController = view
        routingType.previousViewController?.present(view, animated: true)
    }
}
