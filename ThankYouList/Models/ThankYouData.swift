//
//  ThankYouData.swift
//  ThankYouList
//
//  Created by Aika Yamada on 4/18/17.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import Foundation
import Firebase

protocol DocumentSeriarizable {
    init?(dictionary: [String : Any])
}

struct ThankYouData {
    var id: String
    var value: String
    var encryptedValue: String
    var date: Date
    var createTime: Date
    
    var dictionary: [String : Any] {
        return [
            "encryptedValue": encryptedValue,
            "date": date.toThankYouDateString(),
            "createTime": createTime
        ]
    }
}


extension ThankYouData: DocumentSeriarizable {
    init?(dictionary: [String : Any]) {
        guard let encryptedValue = dictionary["encryptedValue"] as? String,
              let dateString = dictionary["date"] as? String,
              let date = dateString.toDate(format: R.string.localizable.date_format_thankyou_date()),
              let createTime = dictionary["createTime"] as? Timestamp else {
            return nil
        }
        self.init(id: "", value: "", encryptedValue: encryptedValue, date: date, createTime: createTime.dateValue())
    }
}


class ThankYouDataUD: NSObject, NSCoding {
    var thankYouValue: String?
    var thankYouDate: String?
    
    override init() {
    }
    
    required init?(coder aDecoder: NSCoder) {
        thankYouValue = aDecoder.decodeObject(forKey: "thankYouValue") as? String
        thankYouDate = aDecoder.decodeObject(forKey : "thankYouDate") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(thankYouValue, forKey: "thankYouValue")
        aCoder.encode(thankYouDate, forKey: "thankYouDate")
    }
}
