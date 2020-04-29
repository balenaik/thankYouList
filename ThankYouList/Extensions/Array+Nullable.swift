//
//  Array+Nullable.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/29.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import Foundation

extension Array {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    func getSafely(at index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}
