//
//  AddPositiveStatementView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/02/09.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

private let contentViewSpacing = CGFloat(16)

struct AddPositiveStatementView: View {
    var body: some View {
        NavigationView {
            contentView
                .screenBackground(Color.defaultBackground)
        }
    }

    var contentView: some View {
        VStack(spacing: contentViewSpacing) {
        }
    }
}

#Preview {
    AddPositiveStatementView()
}
