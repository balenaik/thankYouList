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
    
    /// Returns day
    /// - 02
    /// - 20
    func toDayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        formatter.locale = Locale(identifier: "en")
        return formatter.string(from: self)
    }
    
    /// Returns 3 letters of month in English
    /// - Jan
    func toMonthEnglish3lettersString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "en")
        return formatter.string(from: self)
    }
}
