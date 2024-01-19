//
//  String+Validation.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/04.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Foundation

extension String {
    var isValidMail: Bool {
        return matches(regEx: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    }
}

private extension String {
    func matches(regEx: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES%@", regEx)
        return predicate.evaluate(with: self)
    }
}
