//
//  AlertItem.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/22.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String?
    let primaryAction: AlertAction?
    let secondaryAction: AlertAction?

    init(title: String,
         message: String?,
         primaryAction: AlertAction? = nil,
         secondaryAction: AlertAction? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
}

extension AlertItem {
    var toAlert: Alert {
        let messageText: Text? = if let message {
            Text(message)
        } else {
            nil
        }
        guard let primaryAction else {
            return Alert(title: Text(title), message: messageText)
        }
        guard let secondaryAction else {
            return Alert(title: Text(title),
                         message: messageText,
                         dismissButton: primaryAction.toAlertButton)
        }
        return Alert(title: Text(title),
                     message: messageText,
                     primaryButton: primaryAction.toAlertButton,
                     secondaryButton: secondaryAction.toAlertButton)
    }
}
