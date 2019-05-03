//
//  SettingModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/04/07.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation

struct SettingModel {
    enum TransitionStyle {
        case push
        case modal
        case logout
    }

    enum  Setting: CaseIterable {
        case tags
        case sendAppReview
        case logout

        var title: String {
            switch self {
            // TODO: localize
            case .tags:
                return "タグ"
            case .sendAppReview:
                return "レビューを書く"
            case .logout:
                return "ログアウト"
            }
        }

        var transitionStyle: TransitionStyle {
            switch self {
            case .tags:
                return .push
            case .sendAppReview:
                return .modal
            case .logout:
                return .logout
            }
        }
    }

    var setting: Setting

    init(setting: Setting) {
        self.setting = setting
    }
}
