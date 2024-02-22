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
        List {
        }
        .listBackgroundForIOS16AndAbove(Color.clear)
    }
}

#Preview {
    let viewModel = PositiveStatementListViewModel()
    return PositiveStatementListView(viewModel: viewModel)
}
