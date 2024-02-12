//
//  AddPositiveStatementView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/02/09.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

struct AddPositiveStatementView: View {
    var body: some View {
        NavigationView {
            Text(
                "Hello, World!"
            )
            .navigationBarTitle(R.string.localizable.add_positive_statement_title(), displayMode: .inline)
        }
    }
}

#Preview {
    AddPositiveStatementView()
}
