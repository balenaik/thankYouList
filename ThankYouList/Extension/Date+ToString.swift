//
//  Date+ToString.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/02/02.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation

extension Date {
    /// Returns year and month
    /// - January 2020 (English)
    /// - 2020年1月 (Japanese)
    func toYearMonthString() -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("yMMMM")
        return formatter.string(from: self)
    }
}
