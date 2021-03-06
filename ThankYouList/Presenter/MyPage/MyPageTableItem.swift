//
//  MyPageTableItem.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/25.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import Foundation

// MARK: - TableItem
extension MyPageViewController {
    struct TableItem {
        let item: TableItemType
        let style: TableItemStyle
    }

    enum TableItemType: Int {
        case myInformation
        case logout

        var titleText: String? {
            switch self {
            case .myInformation:
                return nil
            case .logout:
                return R.string.localizable.mypage_logout()
            }
        }
    }

    enum TableItemStyle {
        case profieInfo
        case text
    }
}
