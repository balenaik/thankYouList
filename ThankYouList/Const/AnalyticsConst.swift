//
//  AnalyticsConst.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/06.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import Foundation

enum AnalyticsEventConst {
    static let addThankYou = "add_thankyou"
    static let editThankYou = "edit_thankyou"
    static let deleteThankYou = "delete_thankyou"
    static let tapUserIcon = "tap_usericon"
    static let dragListScrollIndicatorMovableIcon = "drag_list_scroll_indicator_movable_icon"
    static let calendarSmallListViewFullScreen = "calendar_small_list_view_full_screen"
}

enum AnalyticsParameterConst {
    static let userId = "user_id"
    static let targetDate = "target_date"
}
