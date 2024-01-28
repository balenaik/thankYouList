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
        NavigationView {
            List {
            }
        }
    }
}

struct PositiveStatementListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PositiveStatementListViewModel()
        PositiveStatementListView(viewModel: viewModel)
    }
}
