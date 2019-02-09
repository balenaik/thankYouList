//
//  Date+ToString.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/02/02.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation

extension Date {
    
    private static let thankYouDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter
    }()
    
    /// Returns year/month/date
    /// -  2020/01/02
    func toThankYouDateString() -> String {
        return Date.thankYouDateFormatter.string(from: self)
    }
    
    /// Returns year and month
    /// - January 2020 (English)
    /// - 2020年1月 (Japanese)
    func toYearMonthString() -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("yMMMM")
        return formatter.string(from: self)
    }
}
