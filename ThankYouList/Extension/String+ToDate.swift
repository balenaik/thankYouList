//
//  String+ToDate.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/01/30.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation

extension String {
    private static let thankYouDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter
    }()
    
    private static let yearMonthDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM"
        return dateFormatter
    }()
    
    func toThankYouDate() -> Date? {
        return String.thankYouDateFormatter.date(from: self)
    }
    
    func toYearMonthDate() -> Date? {
        return String.yearMonthDateFormatter.date(from: self)
    }
}
