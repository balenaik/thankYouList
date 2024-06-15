//
//  PositiveStatementListView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/01/20.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

private let descriptionFontSize = CGFloat(16)

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
            descriptionSection
        }
        .listStyle(.plain)
        .listBackgroundForIOS16AndAbove(Color.clear)
    }

    private var descriptionSection: some View {
        Section {
            VStack(spacing: 0) {
                Text(R.string.localizable.positive_statement_list_description)
                    .font(.regularAvenir(ofSize: descriptionFontSize))
                    .foregroundStyle(Color.text)
                    .padding(.horizontal, ViewConst.spacing20)
                    .padding(.top, ViewConst.spacing4)
            }
        }
        .listRowBackground(Color.clear)
        .listSectionSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }
}

#Preview {
    let viewModel = PositiveStatementListViewModel()
    return PositiveStatementListView(viewModel: viewModel)
}
