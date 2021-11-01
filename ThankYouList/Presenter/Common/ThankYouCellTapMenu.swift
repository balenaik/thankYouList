//
//  ThankYouCellTapMenu.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2021/11/01.
//  Copyright © 2021 Aika Yamada. All rights reserved.
//

import UIKit

enum ThankYouCellTapMenu: Int, CaseIterable {
    case edit
    case delete

    var title: String {
        switch self {
        case .edit: return R.string.localizable.edit()
        case .delete: return R.string.localizable.delete()
        }
    }

    var image: UIImage? {
        switch self {
        case .edit: return R.image.icEdit24()
        case .delete: return R.image.icDelete24()
        }
    }
}

extension ThankYouCellTapMenu {
    var bottomHalfSheetMenuItem: BottomHalfSheetMenuItem {
        return BottomHalfSheetMenuItem(title: self.title,
                                       image: self.image,
                                       rawValue: self.rawValue)
    }
}
