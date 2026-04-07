//
//  BannerType.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2026/02/05.
//  Copyright © 2026 Aika Yamada. All rights reserved.
//

import UIKit

enum BannerType: Equatable {
    case positiveStatementPromotion
}

extension BannerType {
    var text: String {
        switch self {
        case .positiveStatementPromotion:
            return R.string.localizable.positive_statement_promotion_banner_text()
        }
    }

    var buttonText: String {
        switch self {
        case .positiveStatementPromotion:
            return R.string.localizable.positive_statement_promotion_banner_button_text()
        }
    }

    var image: UIImage? {
        switch self {
        case .positiveStatementPromotion:
            return R.image.icWidget64()
        }
    }
}
