//
//  AnalyticsManager.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/04/16.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import FirebaseAnalytics

protocol AnalyticsManager {
    func logEvent(eventName: String, targetDate: Date?)
    func setUserId(userId: String?)
}

extension AnalyticsManager {
    func logEvent(eventName: String, targetDate: Date? = nil) {
        logEvent(eventName: eventName, targetDate: targetDate)
    }
}

struct DefaultAnalyticsManager: AnalyticsManager {
    func logEvent(eventName: String, targetDate: Date?) {
        var parameters = [String: String]()
        if let targetDate = targetDate {
            parameters[AnalyticsParameterConst.targetDate] = targetDate.toThankYouDateString()
        }
        Analytics.logEvent(eventName, parameters: parameters)
    }

    func setUserId(userId: String?) {
        Analytics.setUserID(userId)
    }
}
