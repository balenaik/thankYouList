//
//  ThankYouData.swift
//  ThankYouList
//
//  Created by Aika Yamada on 4/18/17.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import Foundation

class ThankYouData: NSObject, NSCoding {
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
