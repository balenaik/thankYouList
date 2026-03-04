//
//  ThankYouListBannerView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2026/02/05.
//  Copyright © 2026 Aika Yamada. All rights reserved.
//

import UIKit

class ThankYouListBannerView: UIView {
    class func instanceFromNib() -> ThankYouListBannerView {
        let view = R.nib.thankYouListBannerView.firstView(withOwner: nil)!
        return view
    }
}
