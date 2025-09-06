//
//  WidgetManager.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2025/09/01.
//  Copyright © 2025 Aika Yamada. All rights reserved.
//

import SharedResources
import WidgetKit

protocol WidgetManager {
    func reloadPositiveStatementWidget()
}

struct DefaultWidgetManager: WidgetManager {
    func reloadPositiveStatementWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: AppConst.positiveStatementWidgetKind)
    }
}
