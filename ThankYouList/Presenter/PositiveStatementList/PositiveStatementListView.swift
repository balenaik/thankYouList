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

struct PositiveStatementListView: View {

    @StateObject var viewModel: PositiveStatementListViewModel

    @State private var positiveStatements = [PositiveStatementModel]()

    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
        }
        .screenBackground(Color.defaultBackground)
        .navigationBarTitle(R.string.localizable.positive_statement_list_title(), displayMode: .large)
        .onAppear { viewModel.inputs.onAppear.send() }
        .onReceive(viewModel.outputs.positiveStatements) {
            positiveStatements = $0
        }
    }

    private var contentView: some View {
        List {
            descriptionSection
            positiveStatementsSection
        }
        .listStyle(.plain)
        .listBackgroundForIOS16AndAbove(Color.clear)
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
    }

    private var positiveStatementsSection: some View {
        Section {
            VStack(spacing: 0) {
                ForEach(positiveStatements) { positiveStatement in
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
        }
        .padding(.horizontal, ViewConst.spacing20)
        .padding(.vertical, ViewConst.spacing16)
        .background(Color.white)
    }
}

#Preview {
    let viewModel = PositiveStatementListViewModel(
        userRepository: DefaultUserRepository(),
        positiveStatementRepository: DefaultPositiveStatementRepository(),
        router: nil)
    return PositiveStatementListView(viewModel: viewModel)
}
