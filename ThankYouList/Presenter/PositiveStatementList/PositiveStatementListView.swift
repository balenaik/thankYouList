//
//  PositiveStatementListView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/01/20.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import SwiftUI

private let descriptionFontSize = CGFloat(16)

private let widgetSetupHintButtonFontSize = CGFloat(14)
private let widgetSetupHintBulbIconOpacity = CGFloat(0.9)
private let widgetSetupHintRightArrowIconOpacity = CGFloat(0.5)
private let widgetSetupHintButtonCornerRadius = CGFloat(8)

private let positiveStatementsSectionCornerRadius = CGFloat(12)
private let positiveStatementFontSize = CGFloat(16)
private let positiveStatementRowDotsIconOpacity = CGFloat(0.5)

private let emptyViewImageSize = CGFloat(120)
private let emptyViewTitleFontSize = CGFloat(20)
private let emptyViewDescriptionFontSize = CGFloat(15)
private let emptyViewDescriptionLineSpacing = CGFloat(3)

private let bottomMenuButtonHeight = CGFloat(52)

struct PositiveStatementListView: View {

    // MARK: - Properties

    // To receive output event update in real time,
    // we need to hold outputs itself as a StateObject. viewModel.outputs doesn't work.
    // (There is another way to solve this issue by adding @State property to each output property and use onReceive to update them,
    // but for this view, I chose to hold outputs itself as a StateObject for scalability.)
    private let viewModelInputs: PositiveStatementListViewModel.Inputs
    @StateObject private var viewModelOutputs: PositiveStatementListViewModel.Outputs

    // MARK: - Initializer

    init(viewModel: PositiveStatementListViewModel) {
        viewModelInputs = viewModel.inputs
        _viewModelOutputs = StateObject(wrappedValue: viewModel.outputs)
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
            addButton
        }
        .screenBackground(Color.defaultBackground)
        .navigationBarTitle(R.string.localizable.positive_statement_list_title(), displayMode: .large)
        .flexibleHeightBottomHalfSheet(
            isPresented: $viewModelOutputs.showBottomMenu,
            sheetContent: bottomMenu)
        .onAppear { viewModelInputs.onAppear.send() }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModelOutputs.positiveStatements.isEmpty {
            emptyView
        } else {
            List {
                descriptionSection
                positiveStatementsSection
            }
            .listStyle(.plain)
            .listBackgroundForIOS16AndAbove(Color.clear)
        }
    }

    private var descriptionSection: some View {
        Section {
            VStack(spacing: 0) {
                Text(R.string.localizable.positive_statement_list_description)
                    .font(.regularAvenir(ofSize: descriptionFontSize))
                    .foregroundStyle(Color.text)
                    .padding(.horizontal, ViewConst.spacing20)
                    .padding(.top, ViewConst.spacing4)

                widgetSetupHintButton
                    .padding(.horizontal, ViewConst.spacing20)
                    .padding(.vertical, ViewConst.spacing20)
            }
        }
        .listRowBackground(Color.clear)
        .listSectionSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }

    private var widgetSetupHintButton: some View {
        HStack {
            Image(systemName: SFSymbolConst.lightbulb)
                .imageScale(.medium)
                .foregroundStyle(Color.text.opacity(widgetSetupHintBulbIconOpacity))

            Text(R.string.localizable.positive_statement_list_widget_setup_hint_text)
                .font(.regularAvenir(ofSize: widgetSetupHintButtonFontSize))
                .foregroundStyle(Color.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, ViewConst.spacing12)

            Spacer()

            Image(systemName: SFSymbolConst.chevronRight)
                .imageScale(.small)
                .foregroundStyle(Color.text.opacity(widgetSetupHintRightArrowIconOpacity))
        }
        .padding(.horizontal, ViewConst.spacing12)
        .background(Color.primary100)
        .clipShape(RoundedRectangle(cornerRadius: widgetSetupHintButtonCornerRadius, style: .circular))
        .onTapGesture {
            viewModelInputs.widgetHintButtonDidTap.send()
        }
    }

    private var positiveStatementsSection: some View {
        Section {
            VStack(spacing: 0) {
                ForEach(viewModelOutputs.positiveStatements, id: \.id) { positiveStatement in
                    positiveStatementRow(positiveStatement)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: positiveStatementsSectionCornerRadius, style: .circular))
            .listRowBackground(Color.clear)
            .padding(.bottom, ViewConst.spacing80)
        }
        .listSectionSeparator(.hidden)
    }

    private func positiveStatementRow(_ positiveStatement: PositiveStatementModel) -> some View {
        HStack {
            Text(positiveStatement.value)
                .font(.regularAvenir(ofSize: positiveStatementFontSize))

            Spacer()

            Image(systemName: SFSymbolConst.ellipsis)
                .imageScale(.large)
                .foregroundStyle(Color.text.opacity(positiveStatementRowDotsIconOpacity))
                .padding(.vertical, ViewConst.spacing4)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModelInputs.positiveStatementMenuButtonDidTap.send(positiveStatement.id)
                }
        }
        .padding(.horizontal, ViewConst.spacing20)
        .padding(.vertical, ViewConst.spacing16)
        .background(Color.white)
    }

    private var emptyView: some View {
        VStack {
            Image(R.image.imageEmptyList.name)
                .resizable()
                .frame(width: emptyViewImageSize, height: emptyViewImageSize, alignment: .center)
                .padding(.vertical, ViewConst.spacing16)

            Text(R.string.localizable.positive_statement_empty_title)
                .font(.boldAvenir(ofSize: emptyViewTitleFontSize))
                .foregroundStyle(Color.text)
                .padding(.vertical, ViewConst.spacing4)

            Text(R.string.localizable.positive_statement_list_description)
                .multilineTextAlignment(.center)
                .font(.regularAvenir(ofSize: emptyViewDescriptionFontSize))
                .lineSpacing(emptyViewDescriptionLineSpacing)
                .foregroundStyle(Color.text)
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, ViewConst.spacing20)
        .padding(.bottom, ViewConst.spacing80)
    }
    
    private var addButton: some View {
        Button {
            viewModelInputs.addButtonDidTap.send()
        } label: {
            HStack {
                Image(systemName: SFSymbolConst.squareAndPencil)
                    .font(.regularAvenir(ofSize: ViewConst.fontSize17))
                Text(R.string.localizable.positive_statement_list_add_button_text())
            }
        }
        .disabled(viewModelOutputs.isAddButtonDisabled)
        .buttonStyle(PrimaryButtonStyle())
        .padding(.horizontal, ViewConst.spacing20)
        .padding(.vertical, ViewConst.spacing16)
    }
}

// MARK: - Bottom Half Sheet

private extension PositiveStatementListView {
    var bottomMenu: some View {
        VStack(spacing: 0) {
            ForEach(viewModelOutputs.bottomMenuList, id: \.self) {
                bottomMenuButton(menu: $0)
            }
        }
        .padding(.top, ViewConst.spacing16)
        .padding(.bottom, 1) // To prevent the last menu view look longer than the fixed size while it's hovered
    }

    func bottomMenuButton(menu: PositiveStatementTapMenu) -> some View {
        Button {
            viewModelInputs.bottomMenuDidTap.send(menu)
        } label: {
            HStack(spacing: 0) {
                Image(menu.imageName)
                    .padding(.horizontal, ViewConst.spacing20)
                    .foregroundStyle(Color.black45)

                Text(menu.title)
                    .foregroundStyle(Color.text)
                    .font(.regularAvenir(ofSize: ViewConst.fontSize17))

                Spacer()
            }
            .frame(height: bottomMenuButtonHeight)
        }
        .buttonStyle(BottomMenuButtonStyle())
    }

    private struct BottomMenuButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            return configuration.label
               .foregroundColor(.text)
               .background(configuration.isPressed ? Color.highlight : Color.white)
        }
    }
}

// MARK: - Preview

#Preview {
    let viewModel = PositiveStatementListViewModel(
        userRepository: DefaultUserRepository(),
        positiveStatementRepository: DefaultPositiveStatementRepository(),
        router: nil)
    return PositiveStatementListView(viewModel: viewModel)
}
