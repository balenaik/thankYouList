//
//  String+Bool.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2025/10/24.
//  Copyright © 2025 Aika Yamada. All rights reserved.
//

extension String {
    var boolValue: Bool? {
        switch self.lowercased() {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}
