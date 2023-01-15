//
//  ConfirmDeleteAccountCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/15.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import SwiftUI

class ConfirmDeleteAccountCoordinator: Coordinator {
    var routingType: RoutingType
    var viewController: UIViewController?

    init(presentingViewController: UIViewController) {
        routingType = .modal(presentingViewController: presentingViewController)
    }

    func start() {
        let view = UIHostingController(
            rootView: ConfirmDeleteAccountView(viewModel: ConfirmDeleteAccountViewModel())
        )
        viewController = view
        routingType.previousViewController?.present(view, animated: true)
    }
}
