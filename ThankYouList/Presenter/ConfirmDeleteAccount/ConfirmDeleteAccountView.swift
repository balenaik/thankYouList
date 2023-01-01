//
//  ConfirmDeleteAccountView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2022/12/25.
//  Copyright © 2022 Aika Yamada. All rights reserved.
//

import SwiftUI

private let topSpacerHeight = CGFloat(8)

private let textFieldPadding = CGFloat(16)

private let buttonPadding = CGFloat(16)

private let componentsSideMargin = CGFloat(20)
private let componentsVerticalMargin = CGFloat(8)
private let componentsCornerRadius = CGFloat(16)

struct ConfirmDeleteAccountView: View {

    @StateObject var viewModel: ConfirmDeleteAccountViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color.defaultBackground
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                        .frame(height: topSpacerHeight)

                    Text("Complete your deletion request by entering the email address associated with your account")
                        .font(.regularAvenir(ofSize: 16))
                        .padding(.horizontal, componentsSideMargin)
                        .padding(.vertical, componentsVerticalMargin)

                    TextField("Email address", text: $viewModel.emailAddress)
                        .font(.regularAvenir(ofSize: 16))
                        .padding(.all, textFieldPadding)
                        .background(Color.white)
                        .cornerRadius(componentsCornerRadius)
                        .padding(.horizontal, componentsSideMargin)
                        .padding(.vertical, componentsVerticalMargin)

                    Button("Delete") { }
                    .accentColor(Color.white)
                    .font(.boldAvenir(ofSize: 17))
                    .frame(maxWidth: .infinity)
                    .padding(.all, buttonPadding)
                    .background(Color.redAccent200)
                    .cornerRadius(componentsCornerRadius)
                    .padding(.horizontal, componentsSideMargin)
                    .padding(.vertical, componentsVerticalMargin)

                    Spacer()
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
