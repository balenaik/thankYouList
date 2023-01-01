//
//  ConfirmDeleteAccountView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2022/12/25.
//  Copyright © 2022 Aika Yamada. All rights reserved.
//

import SwiftUI

private let textFieldPadding = CGFloat(16)
private let textFieldCornerRadius = CGFloat(16)

private let componentsSideMargin = CGFloat(20)

struct ConfirmDeleteAccountView: View {

    @StateObject var viewModel: ConfirmDeleteAccountViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color.defaultBackground
                    .ignoresSafeArea()

                VStack {
                    TextField("Email address", text: $viewModel.emailAddress)
                        .padding(.all, textFieldPadding)
                        .background(Color.white)
                        .cornerRadius(textFieldCornerRadius)
                        .padding(.horizontal, componentsSideMargin)
                }
                .navigationBarTitle("Confirm your mail")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                        }
                    }
                }
            }
        }
    }
}

struct ConfirmDeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmDeleteAccountView(viewModel: ConfirmDeleteAccountViewModel())
    }
}
