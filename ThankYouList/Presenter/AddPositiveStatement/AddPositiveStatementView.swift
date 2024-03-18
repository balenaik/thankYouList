//
//  AddPositiveStatementView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/02/09.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

private let titleFontSize = CGFloat(24)
private let descriptionFontSize = CGFloat(16)

struct AddPositiveStatementView: View {
    var body: some View {
        NavigationView {
            contentView
                .screenBackground(Color.defaultBackground)
        }
    }

    var contentView: some View {
        VStack(spacing: ViewConst.spacing16) {
            titleDescriptionView
        }
        .padding(.horizontal, ViewConst.spacing20)
    }

    var titleDescriptionView: some View {
        VStack(spacing: 0) {
            Text(R.string.localizable.add_positive_statement_title)
                .font(.boldAvenir(ofSize: titleFontSize))
                .fixedSize(horizontal: false, vertical: true) // To fix text trancate when TextField grows up
                .padding(.vertical, ViewConst.spacing8)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(R.string.localizable.add_positive_statement_description)
                .font(.regularAvenir(ofSize: descriptionFontSize))
                .fixedSize(horizontal: false, vertical: true) // To fix text trancate issue on iOS 15
                .padding(.vertical, ViewConst.spacing4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    AddPositiveStatementView()
}
