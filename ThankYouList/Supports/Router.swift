//
//  Router.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/14.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit

protocol Router {
    func presentAlert(title: String?,
                      message: String?,
                      actions: [UIAlertAction]?)
}

extension Router {
    func presentAlert(title: String? = nil,
                      message: String? = nil,
                      actions: [UIAlertAction]? = nil) {
        presentAlert(title: title, message: message, actions: actions)
    }
}

// MARK: - Router protocol conforming by Coordinator
extension Coordinator {
    func presentAlert(title: String?, message: String?, actions: [UIAlertAction]?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        if let actions = actions, !actions.isEmpty {
            actions.forEach {
                alertController.addAction($0)
            }
        } else {
            let okAction = UIAlertAction(title: R.string.localizable.ok(), style: .default)
            alertController.addAction(okAction)
        }

        viewController?.present(alertController, animated: true)
    }
}
