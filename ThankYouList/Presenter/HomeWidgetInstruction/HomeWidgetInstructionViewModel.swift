//
//  HomeWidgetInstructionViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/07/14.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

enum HomeWidgetinstructionPage {
    case page1
    case page2
    case page3

    enum NavigationType {
        case modal
        case push
    }

    var navigationType: NavigationType {
        switch self {
        case .page1: return .modal
        case .page2, .page3: return .push
        }
    }
}
