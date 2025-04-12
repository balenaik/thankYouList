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
        statementText
            .padding(ViewConst.spacing12)
            .widgetBackground(color: .primary200)
    }

    private var statementText: some View {
        Text(statement)
            .font(.regularAvenir(ofSize: 16))
            .foregroundColor(.text)
            .showsSkeleton(entry.content.shouldShowSkeleton)
    }

    private var statement: String {
        switch entry.content {
        case .positiveStatement(let statement): statement
        case .loading: "Loading...." // Dummy text for skeleton
        case .errorMessage(let errorMessage): errorMessage
        }
    }
}
