//
//  PositiveStatementWidgetView.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2024/09/22.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

struct PositiveStatementWidgetView : View {
    var entry: PositiveStatementProvider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Emoji:")
            Text(entry.emoji)
        }
    }
}
