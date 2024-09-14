//
//  EditPositiveStatementView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/08/25.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

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
        }
        .padding(.horizontal, ViewConst.spacing24)
    }
}

#Preview {
    EditPositiveStatementView(
        viewModel: EditPositiveStatementViewModel(
            userRepository: DefaultUserRepository(),
            positiveStatementRepository: DefaultPositiveStatementRepository(),
            router: nil))
}
