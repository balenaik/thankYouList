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

    @ObservedObject var viewModel: ConfirmDeleteAccountViewModel

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                Color.defaultBackground
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                        .frame(height: topSpacerHeight)

                    Text(R.string.localizable.confirm_delete_account_description)
                        .font(.regularAvenir(ofSize: 16))
                        .foregroundColor(.text)
                        .padding(.horizontal, componentsSideMargin)
                        .padding(.vertical, componentsVerticalMargin)

                    TextField(viewModel.outputs.emailTextFieldPlaceHolder.value, text: $viewModel.bindings.emailTextFieldText)
                        .font(.regularAvenir(ofSize: 16))
                        .padding(.all, textFieldPadding)
                        .background(Color.white)
                        .cornerRadius(componentsCornerRadius)
                        .padding(.horizontal, componentsSideMargin)
                        .padding(.vertical, componentsVerticalMargin)

                    Button(R.string.localizable.confirm_delete_account_delete_account()) {
                    }
                    .disabled(viewModel.outputs.isDeleteAccountButtonDisabled)
                    .buttonStyle(DeleteAccountButtonStyle())

                    Button(R.string.localizable.cancel()) {
                    }
                    .buttonStyle(CancelButtonStyle())

                    Spacer()
                }
                .navigationBarTitle(R.string.localizable.confirm_delete_account_title())
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            viewModel.inputs.cancelButtonDidTap.send(())
                        }) {
                            Image(R.image.icCancel)
                                .foregroundColor(.text)
                        }
                    }
                }
                .onReceive(viewModel.outputs.dismissView) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

private struct DeleteAccountButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.boldAvenir(ofSize: 17))
            .frame(maxWidth: .infinity)
            .padding(.all, buttonPadding)
            .background(Color.redAccent200)
            .brightness(isEnabled ? 0 : -0.1)
            .cornerRadius(componentsCornerRadius)
            .padding(.horizontal, componentsSideMargin)
            .padding(.vertical, componentsVerticalMargin)
    }
}

private struct CancelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.text)
            .font(.boldAvenir(ofSize: 17))
            .frame(maxWidth: .infinity)
            .padding(.all, buttonPadding)
            .cornerRadius(componentsCornerRadius)
            .padding(.horizontal, componentsSideMargin)
            .padding(.vertical, componentsVerticalMargin)
    }
}

struct ConfirmDeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ConfirmDeleteAccountViewModel(userRepository: DefaultUserRepository())
        ConfirmDeleteAccountView(viewModel: viewModel)
    }
}
