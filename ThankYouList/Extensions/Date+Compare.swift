//
//  Date+Compare.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/09/23.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Foundation

extension Date {
    func isSameDayAs(_ anotherDate: Date) -> Bool {
        Calendar(identifier: .gregorian).isDate(self, inSameDayAs: anotherDate)
    }
}
