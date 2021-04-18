//
//  UIViewController+Alert.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2021/01/07.
//  Copyright © 2021 Aika Yamada. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Present Error Alert
    /// - parameter title: title
    /// - parameter message: message
    /// - parameter buttonTitle: button title
    /// - parameter handler: an event handler when ok button is tapped
    func showErrorAlert(title: String?,
                        message: String?,
                        buttonTitle: String = R.string.localizable.ok(),
                        handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonTitle, style: .default, handler: handler)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
