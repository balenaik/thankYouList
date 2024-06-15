//
//  PositiveStatementListView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/01/20.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

struct PositiveStatementListView: View {

    @StateObject var viewModel: PositiveStatementListViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
        }
        .screenBackground(Color.defaultBackground)
        .navigationBarTitle(R.string.localizable.positive_statement_list_title(), displayMode: .large)
    }

    private var contentView: some View {
        List {
        }
        .listStyle(.plain)
        .listBackgroundForIOS16AndAbove(Color.clear)
    }
}

#Preview {
    let viewModel = PositiveStatementListViewModel()
    return PositiveStatementListView(viewModel: viewModel)
}
