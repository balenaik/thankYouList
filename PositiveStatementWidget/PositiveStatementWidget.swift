//
//  PositiveStatementWidget.swift
//  PositiveStatementWidget
//
//  Created by Aika Yamada on 2024/09/22.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Firebase
import WidgetKit
import SharedResources
import SwiftUI

private let kind: String = "PositiveStatementWidget"

struct PositiveStatementWidget: Widget {

    init() {
        setupFirebase()
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: PositiveStatementProvider()) { entry in
                if #available(iOS 17.0, *) {
                    PositiveStatementWidgetView(entry: entry)
                        .containerBackground(.fill.tertiary, for: .widget)
                } else {
                    PositiveStatementWidgetView(entry: entry)
                        .padding()
                }
            }
            .configurationDisplayName("My Widget")
            .description("This is an example widget.")
    }
}

private extension PositiveStatementWidget {
    func setupFirebase() {
        do {
            FirebaseApp.configure()
            try Auth.auth().useUserAccessGroup(AppConst.teamIdAndAccessGroup)
        } catch let error as NSError {
            // TODO: Log error on Crashlytics
            print("Error setting user access group: %@", error)
        }
    }
}

struct PositiveStatementWidget_Previews: PreviewProvider {
    static var previews: some View {
        PositiveStatementWidgetView(
            entry: PositiveStatementEntry(date: Date(), positiveStatement: "Preview")
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
