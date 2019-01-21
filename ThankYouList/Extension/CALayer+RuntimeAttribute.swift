//
//  CALayer+RuntimeAttribute.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2017/09/05.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
    
    func setBorderIBColor(color: UIColor!) -> Void{
        self.borderColor = color.cgColor
    }
}
