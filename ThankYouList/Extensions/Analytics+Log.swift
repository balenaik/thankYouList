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
    static func logEvent(eventName: String, userId: String, targetDate: Date? = nil) {
        var parameters = [AnalyticsParameterConst.userId: userId]
        if let targetDate = targetDate {
            parameters[AnalyticsParameterConst.targetDate] = targetDate.toThankYouDateString()
        }
        Analytics.logEvent(eventName, parameters: parameters)
    }
}
