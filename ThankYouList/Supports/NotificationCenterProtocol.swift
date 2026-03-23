//
//  NotificationCenterProtocol.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2026/02/18.
//  Copyright © 2026 Aika Yamada. All rights reserved.
//

import Combine
import Foundation

protocol NotificationCenterProtocol {
    func post(_ notification: Notification)
    func publisher(for name: Notification.Name) -> AnyPublisher<Notification, Never>
}

extension NotificationCenter: NotificationCenterProtocol {
    func publisher(for name: Notification.Name) -> AnyPublisher<Notification, Never> {
        publisher(for: name, object: nil).eraseToAnyPublisher()
    }
}
