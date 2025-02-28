//
//  Coordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/09.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

enum RoutingType {
    case push(navigationController: UINavigationController)
    case modal(presentingViewController: UIViewController)
    case none

    var previousViewController: UIViewController? {
        switch self {
        case .push(let viewController):
            return viewController
        case .modal(let viewController):
            return viewController
        case .none:
            return nil
        }
    }

    var navigationController: UINavigationController? {
        switch self {
        case .push(let navigationController):
            return navigationController
        default:
            return nil
        }
    }
}

protocol Coordinator: Router {
    var routingType: RoutingType { get set }
    var viewController: UIViewController? { get set }
    func start()
}

class AppCoordinator: Coordinator {
    var routingType: RoutingType
    weak var viewController: UIViewController?
    private let window: UIWindow
    private let userRepository: UserRepository

    init(window: UIWindow,
         userRepository: UserRepository) {
        routingType = .none
        self.window = window
        self.userRepository = userRepository
    }

    func start() {
        if userRepository.isLoggedIn() {
            let mainTabbarCoordinator = MainTabbarCoordinator(window: window)
            mainTabbarCoordinator.start()
        } else {
            let loginCoordinator = LoginCoordinator(window: window)
            loginCoordinator.start()
        }

        window.makeKeyAndVisible()
    }
}

// MARK: - Deeplink Navigation
extension AppCoordinator {
    func handleDeeplink(url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else {
            throw NavigationError.urlHostNotExist
        }

        switch DeeplinkDestination(rawValue: host) {
        case .positiveStatements:
            navigateToPositiveStatements()
        default:
            throw NavigationError.destinationNotDefined
        }
    }

    private func navigateToPositiveStatements() {
    }
}
