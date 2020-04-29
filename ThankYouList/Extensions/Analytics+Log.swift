//
//  Analytics+Log.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/29.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import Foundation
import Firebase

extension Analytics {
    static func logThankYouEvent(eventName: String, userId: String, targetDate: Date) {
        Analytics.logEvent(eventName, parameters: [
            AnalyticsParameterConst.userId: userId,
            AnalyticsParameterConst.targetDate: targetDate.toThankYouDateString()
        ])
    }

    static func logUserActionEvent(eventName: String, userId: String) {
        Analytics.logEvent(eventName, parameters: [
            AnalyticsParameterConst.userId: userId
        ])
    }
}
