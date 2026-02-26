//
//  MockNotificationCenter.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2026/02/19.
//  Copyright © 2026 Aika Yamada. All rights reserved.
//

import Foundation
@testable import ThankYouList

class MockNotificationCenter: NotificationCenterProtocol {
    var post_notifications = [Notification]()
    var post_calledCount = 0
    func post(_ notification: Notification) {
        post_notifications.append(notification)
        post_calledCount += 1
    }
}
