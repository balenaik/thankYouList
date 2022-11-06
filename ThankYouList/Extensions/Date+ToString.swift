//
//  Date+ToString.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/02/02.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation

extension Date {

    /// Returns year/month/date
    /// -  2020/01/02
    func toThankYouDateString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: self)
    }

    /// Returns year and month
    /// - January 2020 (English)
    /// - 2020年1月 (Japanese)
    func toYearMonthString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.setLocalizedDateFormatFromTemplate("yMMMM")
        return formatter.string(from: self)
    }

    /// Returns year and month and day
    /// - January 1, 2020 (English)
    /// - 2020年1月1日 (Japanese)
    func toYearMonthDayString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateStyle = .long
        return formatter.string(from: self)
    }

    /// Returns day
    /// - 02
    /// - 20
    func toDayString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "dd"
        formatter.locale = Locale(identifier: "en")
        return formatter.string(from: self)
    }

    /// Returns 3 letters of month in English
    /// - Jan
    func toMonthEnglish3lettersString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "en")
        return formatter.string(from: self)
    }

    func toMonthYearString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = R.string.localizable.date_format_month_year()
        return formatter.string(from: self)
    }
}
