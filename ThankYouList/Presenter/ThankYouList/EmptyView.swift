//
//  EmptyView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/08/25.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class EmptyView: UIView {
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = Bundle.main.loadNibNamed("EmptyView", owner: self, options: nil)?.first as! UIView
        self.addSubview(view)
    }
}
