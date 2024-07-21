//
//  HomeWidgetInstructionCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/07/14.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

class HomeWidgetInstructionCoordinator: Coordinator {
    var routingType: RoutingType
    weak var viewController: UIViewController?

    private let page: HomeWidgetinstructionPage

    init?(presentingViewController: UIViewController? = nil,
          navigationController: UINavigationController? = nil,
          page: HomeWidgetinstructionPage) {
        switch page.navigationType {
        case .modal:
            guard let presentingViewController else { return nil }
            routingType = .modal(presentingViewController: presentingViewController)
        case .push:
            guard let navigationController else { return nil }
            routingType = .push(navigationController: navigationController)
            viewController = navigationController
        }
        self.page = page
    }

    func start() {
        let viewModel = HomeWidgetInstructionViewModel(page: page, router: self)
        let hostingController = UIHostingController(
            rootView: HomeWidgetInstructionView(viewModel: viewModel)
        )
        switch page.navigationType {
        case .modal:
            startModal(hostingController)
        case .push:
            startPush(hostingController)
        }
    }

    private func startModal(_ hostingController: UIHostingController<HomeWidgetInstructionView>) {
        let navigationController = UINavigationController(rootViewController: hostingController)
        viewController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)

        routingType.previousViewController?.present(navigationController, animated: true)
    }

    private func startPush(_ hostingController: UIHostingController<HomeWidgetInstructionView>) {
        routingType.navigationController?.pushViewController(hostingController, animated: true)
    }
}

extension HomeWidgetInstructionCoordinator: HomeWidgetinstructionRouter {
    func pushToPage2() {
        guard let navigationController = viewController as? UINavigationController else { return }
        let coordinator = HomeWidgetInstructionCoordinator(
            navigationController: navigationController,
            page: .page2)
        coordinator?.start()
    }

    func pushToPage3() {
        guard let navigationController = viewController as? UINavigationController else { return }
        let coordinator = HomeWidgetInstructionCoordinator(
            navigationController: navigationController,
            page: .page3)
        coordinator?.start()
    }
}
