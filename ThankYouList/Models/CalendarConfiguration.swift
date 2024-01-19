//
//  CalendarConfiguration.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/11/11.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Foundation
import JTAppleCalendar

struct CalendarConfiguration: Equatable {
    let startDate: Date
    let endDate: Date
    let calendar: Calendar
}

extension CalendarConfiguration {
    var toConfigurationParameters: ConfigurationParameters {
        ConfigurationParameters(startDate: startDate,
                                endDate: endDate,
                                calendar: calendar)
    }
}
