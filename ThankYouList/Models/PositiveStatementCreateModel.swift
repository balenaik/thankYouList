//
//  PositiveStatementCreateModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/04/13.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Foundation

struct PositiveStatementCreateModel {
    let encryptedValue: String
    let createdDate: Date
}

// MARK: - Public
extension PositiveStatementCreateModel {
    var dictionary: [String : Any] {
        return [
            "encryptedValue": encryptedValue,
            "createdDate": createdDate
        ]
    }
}
