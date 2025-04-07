//
//  PositiveStatementWidgetView.swift
//  PositiveStatementWidget
//
//  Created by Aika Yamada on 2024/09/22.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SharedResources
import SwiftUI

struct PositiveStatementWidgetView: View {
    var entry: PositiveStatementProvider.Entry

    var body: some View {
        VStack {

            switch entry.content {
            case .positiveStatement(let statement):
                Text("PositiveStatement:")
                Text(statement)
            case .errorMessage(let errorMessage):
                Text(errorMessage)
            }
        }
        .widgetBackground(color: .primary200)
    }
}
