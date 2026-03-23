//
//  MockNotificationCenter.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2026/02/19.
//  Copyright © 2026 Aika Yamada. All rights reserved.
//

import Combine
import Foundation
@testable import ThankYouList

class MockNotificationCenter: NotificationCenterProtocol {
    var post_notifications = [Notification]()
    var post_calledCount = 0
    func post(_ notification: Notification) {
        post_notifications.append(notification)
        post_calledCount += 1
    }

    var publisher_name: Notification.Name?
    var publisher_response = PassthroughSubject<Notification, Never>()
    func publisher(for name: Notification.Name) -> AnyPublisher<Notification, Never> {
        publisher_name = name
        return publisher_response.eraseToAnyPublisher()
    }
}
