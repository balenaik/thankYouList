//
//  String+ToDate.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/01/30.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation

extension String {
    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}
