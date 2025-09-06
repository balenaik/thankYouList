//
//  MockWidgetManager.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2025/09/01.
//  Copyright © 2025 Aika Yamada. All rights reserved.
//

@testable import ThankYouList

class MockWidgetManager: WidgetManager {
    var reloadPositiveStatementWidget_calledCount = 0
    func reloadPositiveStatementWidget() {
        reloadPositiveStatementWidget_calledCount += 1
    }
}
