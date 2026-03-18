//
//  ThankYouListBannerView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2026/02/05.
//  Copyright © 2026 Aika Yamada. All rights reserved.
//

import Combine
import UIKit

private let bannerCornerRadius = CGFloat(16)
private let bannerBorderColor = UIColor.primary
private let bannerBorderWidth = CGFloat(1)

class ThankYouListBannerView: UIView {

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var closeButton: UIButton!

    var closeButtonDidTap: AnyPublisher<Void, Never> {
        closeButton.tapPublisher
    }

    class func instanceFromNib() -> ThankYouListBannerView {
        let view = R.nib.thankYouListBannerView.firstView(withOwner: nil)!
        return view
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = bannerCornerRadius
        cardView.layer.borderColor = bannerBorderColor.cgColor
        cardView.layer.borderWidth = bannerBorderWidth

        // Remove default content insets added by UIButton.Configuration that cannot be overridden in XIB
        var config = actionButton.configuration
        config?.contentInsets = .zero
        actionButton.configuration = config
    }

    func bind(bannerType: BannerType) {
        textLabel.text = bannerType.text
        actionButton.titleLabel?.text = bannerType.buttonText
        iconImageView.image = bannerType.image
    }
}
