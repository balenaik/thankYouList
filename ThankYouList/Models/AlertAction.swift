//
//  AlertAction.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/01/14.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI
import UIKit

class AlertAction {
    let title: String
    let style: Style
    let action: (() -> Void)?

    init(title: String,
         style: AlertAction.Style = .normal,
         action: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.action = action
    }

    enum Style {
        case normal
        case cancel
        case destructive

        var uiAlertActionStyle: UIAlertAction.Style {
            switch self {
            case .normal: return .default
            case .cancel: return .cancel
            case .destructive: return .destructive
            }
        }
    }
}

extension AlertAction {
    var toUIAlertAction: UIAlertAction {
        UIAlertAction(title: title,
                      style: style.uiAlertActionStyle,
                      handler: { _ in self.action?() })
    }

    var toAlertButton: Alert.Button {
        switch style {
        case .normal: .default(Text(title), action: action ?? {})
        case .cancel: .cancel(Text(title), action: action ?? {})
        case .destructive: .destructive(Text(title), action: action ?? {})
        }
    }
}

