//
//  AnalyticsManager.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/04/16.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import FirebaseAnalytics

protocol AnalyticsManager {
    func logEvent(eventName: String, userId: String, targetDate: Date?)
    func setUserId(userId: String?)
}

extension AnalyticsManager {
    func logEvent(eventName: String, userId: String, targetDate: Date? = nil) {
        logEvent(eventName: eventName, userId: userId, targetDate: targetDate)
    }
}

struct DefaultAnalyticsManager: AnalyticsManager {
    func logEvent(eventName: String, userId: String, targetDate: Date?) {
        var parameters = [AnalyticsParameterConst.userId: userId]
        if let targetDate = targetDate {
            parameters[AnalyticsParameterConst.targetDate] = targetDate.toThankYouDateString()
        }
        Analytics.logEvent(eventName, parameters: parameters)
    }

    func setUserId(userId: String?) {
        Analytics.setUserID(userId)
    }
}
