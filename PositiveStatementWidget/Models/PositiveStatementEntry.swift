//
//  PositiveStatementEntry.swift
//  PositiveStatementWidget
//
//  Created by Aika Yamada on 2024/09/24.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import WidgetKit

struct PositiveStatementEntry: TimelineEntry {
    let date: Date
    let content: PositiveStatementContentType
}

enum PositiveStatementContentType {
    case positiveStatement(String)
    case loading
    case errorMessage(String)

    var shouldShowSkeleton: Bool {
        switch self {
        case .loading: true
        default: false
        }
    }
}
