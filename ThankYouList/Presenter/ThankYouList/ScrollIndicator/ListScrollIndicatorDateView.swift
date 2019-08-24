//
//  ListScrollIndicatorDateView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/08/13.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

class ListScrollIndicatorDateView: UIView {
    class func instanceFromNib() -> ListScrollIndicatorDateView {
        let view = Bundle.main.loadNibNamed("ListScrollIndicatorDateView", owner: self, options: nil)?.first as! ListScrollIndicatorDateView
        return view
    }
}
