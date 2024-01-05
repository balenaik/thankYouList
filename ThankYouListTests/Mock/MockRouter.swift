//
//  MockRouter.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2024/01/05.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import UIKit
@testable import ThankYouList

class MockRouter: Router {
    var presentAlert_title: String?
    var presentAlert_message: String?
    var presentAlert_actions: [UIAlertAction]?
    var presentAlert_calledCount = 0
    func presentAlert(title: String?,
                      message: String?,
                      actions: [UIAlertAction]?) {
        presentAlert_title = title
        presentAlert_message = message
        presentAlert_actions = actions
        presentAlert_calledCount += 1
    }
}
