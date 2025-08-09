//
//  PositiveStatementUpdateModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2025/05/16.
//  Copyright © 2025 Aika Yamada. All rights reserved.
//

import Foundation

struct PositiveStatementUpdateModel {
    let encryptedValue: String
    let createdDate: Date
}

// MARK: - Public
extension PositiveStatementUpdateModel {
    var dictionary: [String : Any] {
        return [
            "encryptedValue": encryptedValue,
            "createdDate": createdDate
        ]
    }
}
