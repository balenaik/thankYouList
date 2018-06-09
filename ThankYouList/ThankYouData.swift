//
//  ThankYouData.swift
//  ThankYouList
//
//  Created by Aika Yamada on 4/18/17.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import Foundation

protocol DocumentSeriarizable {
    init?(dictionary: [String : Any])
}

struct ThankYouData {
    var value: String
    var date: String
    var timeStamp: Date
    
    var dictionary: [String : Any] {
        return [
            "value": value,
            "date": date,
            "timeStamp": timeStamp
        ]
    }
}


extension ThankYouData: DocumentSeriarizable {
    init?(dictionary: [String : Any]) {
        guard let value = dictionary["value"] as? String,
            let date = dictionary["date"] as? String,
            let timeStamp = dictionary["timeStamp"] as? Date else {
                return nil
        }
        self.init(value: value, date: date, timeStamp: timeStamp)
    }
    
}



class ThankYouDataUD: NSObject {
    var thankYouValue: String?
    var thankYouDate: String?
    
    required init(coder aDecoder: NSCoder) {
        thankYouValue = aDecoder.decodeObject(forKey: "thankYouValue") as? String
        thankYouDate = aDecoder.decodeObject(forKey : "thankYouDate") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(thankYouValue, forKey: "thankYouValue")
        aCoder.encode(thankYouDate, forKey: "thankYouDate")
    }
}
