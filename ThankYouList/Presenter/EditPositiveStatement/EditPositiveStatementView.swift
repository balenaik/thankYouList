//
//  EditPositiveStatementView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/08/25.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

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
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

#Preview {
    EditPositiveStatementView(
        viewModel: EditPositiveStatementViewModel(
            userRepository: DefaultUserRepository(),
            positiveStatementRepository: DefaultPositiveStatementRepository(),
            router: nil))
}
