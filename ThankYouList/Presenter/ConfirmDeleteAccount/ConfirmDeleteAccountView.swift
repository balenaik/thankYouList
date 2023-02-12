//
//  ConfirmDeleteAccountView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2022/12/25.
//  Copyright © 2022 Aika Yamada. All rights reserved.
//

import SwiftUI

private let topSpacerHeight = CGFloat(8)

private let textFieldPadding = CGFloat(12)

private let buttonPadding = CGFloat(12)

private let componentsSideMargin = CGFloat(20)
private let componentsVerticalMargin = CGFloat(8)
private let componentsCornerRadius = CGFloat(16)

struct ConfirmDeleteAccountView: View {

    @ObservedObject var viewModel: ConfirmDeleteAccountViewModel

    @State private var alertItem: AlertItem?

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

                    TextField(viewModel.outputs.emailTextFieldPlaceHolder.value,
                              text: $viewModel.bindings.emailTextFieldText)
                        .font(.regularAvenir(ofSize: 16))
                        .padding(.all, textFieldPadding)
                        .background(Color.white)
                        .cornerRadius(componentsCornerRadius)
                        .padding(.horizontal, componentsSideMargin)
                        .padding(.vertical, componentsVerticalMargin)

                    Button(R.string.localizable.confirm_delete_account_delete_account()) {
                        viewModel.inputs.deleteAccountButtonDidTap.send(())
                    }
                    .disabled(viewModel.outputs.isDeleteAccountButtonDisabled)
                    .buttonStyle(DeleteAccountButtonStyle())

                    Button(R.string.localizable.cancel()) {
                        viewModel.inputs.cancelButtonDidTap.send(())
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
                .alert(item: $alertItem) { alertItem in
                    Alert(title: Text(alertItem.title),
                          message: Text(alertItem.message),
                          dismissButton: .default(Text(R.string.localizable.ok()),
                                                  action: alertItem.okAction))
                }
            }
        }
        .accentColor(.text) // Remove this when finish supporting iOS 14.x
        .onReceive(viewModel.bindings.$alertItem) { alertItem in
            self.alertItem = alertItem
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
        let viewModel = ConfirmDeleteAccountViewModel(userRepository: DefaultUserRepository(),
                                                      router: nil)
        ConfirmDeleteAccountView(viewModel: viewModel)
    }
}
