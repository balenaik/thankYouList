//
//  PositiveStatementWidgetError.swift
//  PositiveStatementWidgetExtension
//
//  Created by Aika Yamada on 2025/01/12.
//  Copyright © 2025 Aika Yamada. All rights reserved.
//

enum PositiveStatementWidgetError: Error {
    case currentUserNotExist
    case dataNotFound
}

extension PositiveStatementWidgetError {
    var errorMessage: String {
        // TODO: Localize them after R.swift supports Strings catalogs
        switch self {
        case .currentUserNotExist:
            return "Please log in"
        case .dataNotFound:
            return "Please add Positive Statement"
        }
    }
}
