//
//  HomeWidgetInstructionView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/07/14.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

private let titleFontSize = CGFloat(24)

private let imageWidth = CGFloat(150)
private let imageHeight = CGFloat(300)

private let descriptionFontSize = CGFloat(16)

struct HomeWidgetInstructionView: View {
    var body: some View {
        NavigationView {
            contentView
                .screenBackground(Color.defaultBackground)
                .cancelButtonToolbar {}
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            Text(R.string.localizable.home_widget_instruction_title)
                .font(.boldAvenir(ofSize: titleFontSize))
                .foregroundStyle(Color.text)

            Image(R.image.imageHomeWidgetInstructionPage1.name)
                .resizable()
                .frame(width: imageWidth, height: imageHeight)
                .padding(.vertical, ViewConst.spacing24)

            Text(R.string.localizable.home_widget_instruction_page1_description)
                .font(.regularAvenir(ofSize: descriptionFontSize))
                .foregroundStyle(Color.text)
                .multilineTextAlignment(.center)
                .padding(.vertical, ViewConst.spacing12)

            Spacer(minLength: 0)

            Button(R.string.localizable.next()) { }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.vertical, ViewConst.spacing16)
        }
        .padding(.horizontal, ViewConst.spacing20)
    }
}
