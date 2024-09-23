//
//  PositiveStatementWidget.swift
//  PositiveStatementWidget
//
//  Created by Aika Yamada on 2024/09/22.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import WidgetKit
import SwiftUI

private let kind: String = "PositiveStatementWidget"

struct PositiveStatementWidget: Widget {
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
                        .background()
                }
            }
            .configurationDisplayName("My Widget")
            .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    PositiveStatementWidget()
} timeline: {
    PositiveStatementEntry(date: .now, emoji: "😀")
    PositiveStatementEntry(date: .now, emoji: "🤩")
}
