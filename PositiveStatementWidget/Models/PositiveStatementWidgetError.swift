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
        switch self {
        case .currentUserNotExist:
            return String(localized: "error_not_logged_in")
        case .dataNotFound:
            return String(localized: "error_data_not_found")
        }
    }
}
