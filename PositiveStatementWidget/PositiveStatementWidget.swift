//
//  PositiveStatementWidget.swift
//  PositiveStatementWidget
//
//  Created by Aika Yamada on 2024/09/22.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Firebase
import FirebaseAuth
import WidgetKit
import SharedResources
import SwiftUI

struct PositiveStatementWidget: Widget {

    init() {
        setupFirebase()
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: AppConst.positiveStatementWidgetKind,
            provider: PositiveStatementProvider()) { entry in
                PositiveStatementWidgetView(entry: entry)
            }
            .configurationDisplayName(String(localized: "widget_title"))
            .description(String(localized: "widget_description"))
    }
}

private extension PositiveStatementWidget {
    func setupFirebase() {
        do {
            safeConfigureFirebase()
            try Auth.auth().useUserAccessGroup(AppConst.teamIdAndAccessGroup)
        } catch let error as NSError {
            // TODO: Log error on Crashlytics
            print("Error setting user access group: %@", error)
        }
    }

    func safeConfigureFirebase() {
        if ProcessInfo.processInfo.environment["CI"] == "true" {
            // In case of CI test, don't configure FirebaseApp
            return
        }
        FirebaseApp.configure()
    }
}

struct PositiveStatementWidget_Previews: PreviewProvider {
    static var previews: some View {
        PositiveStatementWidgetView(
            entry: PositiveStatementEntry(date: Date(), content: .positiveStatement("Preview"))
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
