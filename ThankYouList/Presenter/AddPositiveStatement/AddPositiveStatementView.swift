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

private let textFieldMinLine = 2
private let textFieldFontSize = CGFloat(16)
private let textFieldPlaceHolderOpacity = CGFloat(0.25)
private let textFieldCornerRadius = CGFloat(8)

private let characterCounterTextFontSize = CGFloat(13)

private let doneButtonFontSize = CGFloat(17)
private let doneButtonCornerRadius = CGFloat(16)

struct AddPositiveStatementView: View {
    @StateObject var viewModel: AddPositiveStatementViewModel

    var body: some View {
        NavigationView {
            contentView
                .screenBackground(Color.defaultBackground)
                .onReceive(viewModel.outputs.closeKeyboard) { _ in
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil)
                }
        }
        .interactiveDismissDisabled(true)
    }

    var contentView: some View {
        VStack(spacing: ViewConst.spacing16) {
            titleDescriptionView
            textFieldView
            doneButton
            Spacer()
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

    var textFieldView: some View {
        VStack {
            textField(R.string.localizable.add_positive_statement_textfield_placeholder(), text: $viewModel.bindings.textFieldText)
                .font(.regularAvenir(ofSize: textFieldFontSize))
                .padding(.all, ViewConst.spacing12)
                .background(Color.white)
                .cornerRadius(textFieldCornerRadius)
                .onChange(of: viewModel.bindings.textFieldText) { text in
                    viewModel.inputs.textFieldTextDidChange.send(text)
                }

            Text(viewModel.outputs.characterCounterText.value)
                .font(.regularAvenir(ofSize: characterCounterTextFontSize))
                .foregroundStyle(viewModel.outputs.characterCounterColor.value.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    @ViewBuilder
    func textField(_ placeHolder: String, text: Binding<String>) -> some View {
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

    var doneButton: some View {
        Button(R.string.localizable.done()) {
        }
        .buttonStyle(DoneButtonStyle())
    }

    private struct DoneButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
               .font(.boldAvenir(ofSize: doneButtonFontSize))
               .frame(maxWidth: .infinity)
               .padding(.all, ViewConst.spacing12)
               .cornerRadius(doneButtonCornerRadius)
        }
    }
}

#Preview {
    AddPositiveStatementView(viewModel: AddPositiveStatementViewModel())
}
