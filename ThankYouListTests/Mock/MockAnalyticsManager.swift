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
    var logEvent_eventName: String?
    var logEvent_userId: String?
    var logEvent_targetDate: Date?
    func logEvent(eventName: String, userId: String, targetDate: Date?) {
        logEvent_eventName = eventName
        logEvent_userId = userId
        logEvent_targetDate = targetDate
    }
}
