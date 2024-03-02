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
            contentView
                .screenBackground(Color.defaultBackground)
        }
    }

    var contentView: some View {
        VStack(spacing: ViewConst.spacing16) {
        }
        .padding(.horizontal, ViewConst.spacing20)
    }
}

#Preview {
    AddPositiveStatementView()
}
