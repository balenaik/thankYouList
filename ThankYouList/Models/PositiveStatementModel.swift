//
//  PositiveStatementModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/04/15.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Foundation

struct PositiveStatementModel: Identifiable {
    let id = UUID()
    let value: String
    let createdDate: Date
}
