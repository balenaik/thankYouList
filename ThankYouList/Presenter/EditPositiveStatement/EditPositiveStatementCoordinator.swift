//
//  EditPositiveStatementCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/08/25.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

class EditPositiveStatementCoordinator: Coordinator {
    var routingType: RoutingType
    weak var viewController: UIViewController?
    private let positiveStatementId: String

    init(positiveStatementId: String, presentingViewController: UIViewController) {
        self.positiveStatementId = positiveStatementId
        routingType = .modal(presentingViewController: presentingViewController)
    }

    func start() {
        let viewModel = EditPositiveStatementViewModel(
            positiveStatementId: positiveStatementId, 
            userRepository: DefaultUserRepository(),
            positiveStatementRepository: DefaultPositiveStatementRepository(),
            router: self)
        let view = UIHostingController(
            rootView: EditPositiveStatementView(viewModel: viewModel)
        )
        viewController = view
        routingType.previousViewController?.present(view, animated: true)
    }
}

extension EditPositiveStatementCoordinator: EditPositiveStatementRouter {
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
}
