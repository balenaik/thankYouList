//
//  LocalizedLabel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/09/04.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class LocalizedLabel: UILabel {
    @IBInspectable var localizedText:String {
        set(key){
            self.text = NSLocalizedString(key, comment: "")
        }
        get{
            return text!
        }
    }
}
