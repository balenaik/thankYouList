//
//  MyPageTableItem.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/25.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import UIKit

// MARK: - TableItem
extension MyPageViewController {
    struct TableItem {
        let item: TableItemType
        let style: TableItemStyle
    }

    enum TableItemType: Int {
        case myInformation
        case logout
        case deleteAccount

        var titleText: String? {
            switch self {
            case .myInformation:
                return nil
            case .logout:
                return R.string.localizable.mypage_logout()
            case .deleteAccount:
                return R.string.localizable.mypage_delete_account()
            }
        }

        var titleColor: UIColor? {
            switch self {
            case .myInformation:
                return nil
            case .logout:
                return .text
            case .deleteAccount:
                return .redAccent200
            }
        }
    }

    enum TableItemStyle {
        case profieInfo
        case button
    }
}
