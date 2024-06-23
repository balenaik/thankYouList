//
//  PositiveStatementListCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/01/21.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

class PositiveStatementListCoordinator: Coordinator {
    var routingType: RoutingType
    weak var viewController: UIViewController?

    init(navigationController: UINavigationController) {
        routingType = .push(navigationController: navigationController)
    }

    func start() {
        let viewModel = PositiveStatementListViewModel(
            userRepository: DefaultUserRepository(),
            positiveStatementRepository: DefaultPositiveStatementRepository(),
            router: self
        )
        let view = UIHostingController(
            rootView: PositiveStatementListView(viewModel: viewModel)
        )
        viewController = view
        routingType.navigationController?.pushViewController(view, animated: true)
    }
}

extension PositiveStatementListCoordinator: PositiveStatementListRouter {
    func popToPreviousScreen() {
        routingType.navigationController?.popViewController(animated: true)
    }
}
