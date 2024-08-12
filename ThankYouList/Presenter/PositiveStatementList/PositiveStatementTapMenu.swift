//
//  PositiveStatementTapMenu.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/08/04.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

enum PositiveStatementTapMenu: Int, CaseIterable {
    case edit
    case delete

    var title: String {
        switch self {
        case .edit: return R.string.localizable.edit()
        case .delete: return R.string.localizable.delete()
        }
    }

    var imageName: String {
        switch self {
        case .edit: return R.image.icEdit24.name
        case .delete: return R.image.icDelete24.name
        }
    }
}
