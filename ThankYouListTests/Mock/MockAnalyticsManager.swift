//
//  MockAnalyticsManager.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2023/04/19.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Foundation
@testable import ThankYouList

class MockAnalyticsManager: AnalyticsManager {
    struct AnalyticsEvent {
        let eventName: String
        let userId: String
        let targetDate: Date?
    }

    var loggedEvent = [AnalyticsEvent]()
    func logEvent(eventName: String, userId: String, targetDate: Date?) {
        loggedEvent.append(AnalyticsEvent(
            eventName: eventName,
            userId: userId,
            targetDate: targetDate))
    }
}
