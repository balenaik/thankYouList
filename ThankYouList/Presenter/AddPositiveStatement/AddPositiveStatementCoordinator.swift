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
        let viewModel = AddPositiveStatementViewModel(
            userRepository: DefaultUserRepository(),
            positiveStatementRepository: DefaultPositiveStatementRepository(),
            analyticsManager: DefaultAnalyticsManager(),
            widgetManager: DefaultWidgetManager(),
            router: self)
        let view = UIHostingController(
            rootView: AddPositiveStatementView(viewModel: viewModel)
        )
        viewController = view
        routingType.previousViewController?.present(view, animated: true)
    }
}

extension AddPositiveStatementCoordinator: AddPositiveStatementRouter {
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
}
