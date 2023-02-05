//
//  AlertItem.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/22.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Foundation

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
