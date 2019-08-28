//
//  ListScrollIndicatorTitleView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/08/13.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

class ListScrollIndicatorTitleView: UIView {
    @IBOutlet weak var titleLabel: UILabel!

    class func instanceFromNib() -> ListScrollIndicatorTitleView {
        let view = Bundle.main.loadNibNamed("ListScrollIndicatorTitleView", owner: self, options: nil)?.first as! ListScrollIndicatorTitleView
        return view
    }

    func bind(title: String) {
        titleLabel.text = title
    }
}
