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
    static let showMyPage = "show_mypage"
    static let deleteAccount = "delete_account"
    static let startDraggingListScrollIndicatorMovableIcon = "start_dragging_scroll_indicator"
    static let calendarSmallListViewFullScreen = "calendar_small_list_view_full_screen"
    static let scrollCalendar = "scroll_calendar"
    static let openPositiveStatementList = "open_positive_statement_list"
    static let openHomeWidgetInstruction = "open_home_widget_instruction"
}

enum AnalyticsParameterConst {
    static let userId = "user_id"
    static let targetDate = "target_date"
}
