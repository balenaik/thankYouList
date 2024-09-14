//
//  EditPositiveStatementView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/08/25.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

private let textFieldMinLine = 2
private let textFieldPlaceHolderOpacity = CGFloat(0.25)
private let textFieldCornerRadius = CGFloat(8)

struct EditPositiveStatementView: View {
    private let viewModelInputs: EditPositiveStatementViewModel.Inputs
    @StateObject private var viewModelOutputs: EditPositiveStatementViewModel.Outputs
    @StateObject private var viewModelBindings: EditPositiveStatementViewModel.Bindings

    init(viewModel: EditPositiveStatementViewModel) {
        viewModelInputs = viewModel.inputs
        _viewModelOutputs = StateObject(wrappedValue: viewModel.outputs)
        _viewModelBindings = StateObject(wrappedValue: viewModel.bindings)
    }

    var body: some View {
        NavigationView {
            contentView
                .offsetDetectableScrollView(offsetSubject: viewModelInputs.scrollViewOffsetDidChange)
                .screenBackground(Color.defaultBackground)
                .cancelButtonToolbar { viewModelInputs.cancelButtonDidTap.send() }
                .navigationTitle(viewModelOutputs.navigationBarTitle)
                .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled(true)
        .onReceive(viewModelOutputs.closeKeyboard) { _ in
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil)
        }
        .proccessingOverlay(isProcessing: $viewModelOutputs.isProcessing)
    }

    private var contentView: some View {
        VStack(spacing: ViewConst.spacing16) {
            titleDescriptionView
            textFieldView
            doneButton
            Spacer()
        }
        .padding(.horizontal, ViewConst.spacing24)
    }

    private var titleDescriptionView: some View {
        VStack(spacing: 0) {
            Text(R.string.localizable.edit_positive_statement_title)
                .font(.boldAvenir(ofSize: ViewConst.fontSize24))
                .fixedSize(horizontal: false, vertical: true) // To fix text trancate when TextField grows up
                .padding(.vertical, ViewConst.spacing8)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(R.string.localizable.edit_positive_statement_description)
                .font(.regularAvenir(ofSize: ViewConst.fontSize16))
                .fixedSize(horizontal: false, vertical: true) // To fix text trancate issue on iOS 15
                .padding(.vertical, ViewConst.spacing4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var textFieldView: some View {
        VStack {
            textField(R.string.localizable.edit_positive_statement_textfield_placeholder(), text: $viewModelBindings.textFieldText)
                .font(.regularAvenir(ofSize: ViewConst.fontSize16))
                .padding(.all, ViewConst.spacing12)
                .background(Color.white)
                .cornerRadius(textFieldCornerRadius)
                .onChange(of: viewModelBindings.textFieldText) { text in
                    viewModelInputs.textFieldTextDidChange.send(text)
                }

            Text(viewModelOutputs.characterCounterText.value)
                .font(.regularAvenir(ofSize: ViewConst.fontSize13))
                .foregroundStyle(viewModelOutputs.characterCounterColor.value.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    @ViewBuilder
    private func textField(_ placeHolder: String, text: Binding<String>) -> some View {
        if #available(iOS 16.0, *) {
            ZStack {
                // Prepare custom placeholder rather than build-in placeholder
                // in order to show multiline placeholder
                TextField("", text: text, axis: .vertical)
                    .lineLimit(textFieldMinLine...)
                if text.wrappedValue.isEmpty {
                    HStack {
                        Text(placeHolder)
                            .opacity(textFieldPlaceHolderOpacity)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .allowsHitTesting(false)
                    }
                }
            }
        } else {
            // iOS 15 or lower doesn't support multiline textField
            TextField(placeHolder, text: text)
        }
    }

    private var doneButton: some View {
        Button(R.string.localizable.done()) {
            viewModelInputs.doneButtonDidTap.send()
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

#Preview {
    EditPositiveStatementView(
        viewModel: EditPositiveStatementViewModel(
            positiveStatementId: "",
            userRepository: DefaultUserRepository(),
            positiveStatementRepository: DefaultPositiveStatementRepository(),
            router: nil))
}
