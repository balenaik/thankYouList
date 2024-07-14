//
//  PositiveStatementListCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/01/21.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import SwiftUI

class PositiveStatementListCoordinator: Coordinator {
    var routingType: RoutingType
    weak var viewController: UIViewController?

    private var cancellable = Set<AnyCancellable>()

    init(navigationController: UINavigationController) {
        routingType = .push(navigationController: navigationController)
    }

    func start() {
        let viewModel = PositiveStatementListViewModel(
            userRepository: DefaultUserRepository(),
            positiveStatementRepository: DefaultPositiveStatementRepository(),
            router: self
        )
        let view = ViewLifecycleAwareHostingController(
            rootView: PositiveStatementListView(viewModel: viewModel)
        )
        viewController = view

        view.viewWillAppearRelay
            .sink { [weak self] _ in
                // This setup needs to be on viewWillAppear to always show large title
                // even when a user tries to use swipe to back but cancels it
                self?.routingType.navigationController?.navigationBar.prefersLargeTitles = true
            }
            .store(in: &cancellable)

        routingType.navigationController?.pushViewController(view, animated: true)
    }
}

extension PositiveStatementListCoordinator: PositiveStatementListRouter {
    func popToPreviousScreen() {
        routingType.navigationController?.popViewController(animated: true)
    }

    func presentAddPositiveStatement() {
        guard let viewController = viewController else { return }
        let coordinator = AddPositiveStatementCoordinator(presentingViewController: viewController)
        coordinator.start()
    }
}
