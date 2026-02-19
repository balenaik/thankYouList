//
//  NotificationCenterProtocol.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2026/02/18.
//  Copyright © 2026 Aika Yamada. All rights reserved.
//

import Foundation

protocol NotificationCenterProtocol {
    func post(_ notification: Notification)
}

extension NotificationCenter: NotificationCenterProtocol {}
