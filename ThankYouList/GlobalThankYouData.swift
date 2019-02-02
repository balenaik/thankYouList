//
//  GlobalThankYouData.swift
//  ThankYouList
//
//  Created by Aika Yamada on 6/10/17.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import Foundation

class GlobalThankYouData {
    
    // Create a singleton
    var thankYouDataUDList = [ThankYouDataUD]()
    var thankYouDataList = [ThankYouData]()
    
    // Get instance
    static var sharedInstance = GlobalThankYouData()

        
    // Init
    private init() {
    }
    
    
}
