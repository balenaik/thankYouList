//
//  ThankYouListBannerView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2026/02/05.
//  Copyright © 2026 Aika Yamada. All rights reserved.
//

import UIKit

private let bannerCornerRadius = CGFloat(16)
private let bannerBorderColor = UIColor.primary
private let bannerBorderWidth = CGFloat(1)

class ThankYouListBannerView: UIView {

    @IBOutlet private weak var cardView: UIView!

    class func instanceFromNib() -> ThankYouListBannerView {
        let view = R.nib.thankYouListBannerView.firstView(withOwner: nil)!
        return view
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = bannerCornerRadius
        cardView.layer.borderColor = bannerBorderColor.cgColor
        cardView.layer.borderWidth = bannerBorderWidth
    }
}
