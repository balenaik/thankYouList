//
//  EditPositiveStatementViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/08/25.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import Foundation
import SharedResources

private let positiveStatementMaxCount = 100

protocol EditPositiveStatementRouter: Router {
    func dismiss()
}

class EditPositiveStatementViewModel: ObservableObject {

    let inputs = Inputs()
    let outputs = Outputs()
    @Published var bindings = Bindings()

    private let positiveStatementId: String
    private var cancellable = Set<AnyCancellable>()
    private let userRepository: UserRepository
    private let positiveStatementRepository: PositiveStatementRepository
    private let analyticsManager: AnalyticsManager
    private let widgetManager: WidgetManager
    private let router: EditPositiveStatementRouter?

    init(positiveStatementId: String,
         userRepository: UserRepository,
         positiveStatementRepository: PositiveStatementRepository,
         analyticsManager: AnalyticsManager,
         widgetManager: WidgetManager,
         router: EditPositiveStatementRouter?) {
        self.positiveStatementId = positiveStatementId
        self.router = router
        self.userRepository = userRepository
        self.positiveStatementRepository = positiveStatementRepository
        self.analyticsManager = analyticsManager
        self.widgetManager = widgetManager
        bind()
    }
}

private extension EditPositiveStatementViewModel {
    func bind() {
        inputs.scrollViewOffsetDidChange
            .map {
                $0 > ViewConst.swiftUINavigationTitleVisibleOffset
                ? R.string.localizable.edit_positive_statement_title()
                : ""
            }
            .removeDuplicates()
            .assign(to: &outputs.$navigationBarTitle)

        let profile = inputs.onAppear
            .first()
            .flatMap { [userRepository] in
                userRepository.getUserProfile()
            }
            .shareReplay(1)

        let positiveStatement = profile
            .withUnretained(self)
            .flatMap { owner, profile in
                owner.positiveStatementRepository
                    .getPositiveStatement(
                        positiveStatementId: owner.positiveStatementId,
                        userId: profile.id
                    )
                    .asResult()
            }
            .catch { Just(.failure($0)) }
            .share()

        positiveStatement
            .values()
            .map { $0.value }
            .assign(to: &bindings.$textFieldText)

        positiveStatement
            .errors()
            .map { [router] _ in
                AlertItem(
                    title: R.string.localizable.edit_positive_statement_edit_error(),
                    message: nil,
                    primaryAction: .init(
                        title: R.string.localizable.ok(),
                        action: {
                            router?.dismiss()
                        }
                    )
                )
            }
            .assign(to: &outputs.$showAlert)

        inputs.textFieldTextDidChange
            .compactMap { text in
                // Don't allow a line with only newline character
                guard text.suffix(2).allSatisfy({ $0.isNewline }) else {
                    return nil
                }
                return String(text.dropLast())
            }
            .sendEvent((), to: outputs.closeKeyboard)
            .assign(to: &bindings.$textFieldText)

        bindings.$textFieldText
            .map {
                R.string.localizable
                    .edit_positive_statement_character_count_text(
                        String($0.count),
                        String(positiveStatementMaxCount))
            }
            .subscribe(outputs.characterCounterText)
            .store(in: &cancellable)

        bindings.$textFieldText
            .map {
                $0.count > positiveStatementMaxCount
                ? ThemeColor.redAccent200
                : ThemeColor.text
            }
            .subscribe(outputs.characterCounterColor)
            .store(in: &cancellable)

        bindings.$textFieldText
            .removeDuplicates()
            .dropFirst(2) // Skip initial empty value & original statement
            .map { $0.isEmpty || $0.count > positiveStatementMaxCount }
            .subscribe(outputs.isDoneButtonDisabled)
            .store(in: &cancellable)

        inputs.cancelButtonDidTap
            .sink { [router] in router?.dismiss() }
            .store(in: &cancellable)

        inputs.doneButtonDidTap
            .subscribe(outputs.closeKeyboard)
            .store(in: &cancellable)

        let editPositiveStatementResult = inputs.doneButtonDidTap
            .handleEvents(receiveOutput: { [outputs] in outputs.isProcessing = true })
            .map { [bindings] in bindings.textFieldText }
            .withUnretained(self)
            .flatMap { [userRepository, positiveStatementRepository] owner, positiveStatement in
                userRepository.getUserProfile().map { ($0, positiveStatement) }
                    .flatMap { userProfile, positiveStatement in
                        positiveStatementRepository
                            .updatePositiveStatement(
                                positiveStatementId: owner.positiveStatementId,
                                positiveStatement: positiveStatement,
                                userId: userProfile.id)
                    }
                    .asResult()
            }
            .handleEvents(receiveOutput: { [outputs] _ in outputs.isProcessing = false })
            .share()

        editPositiveStatementResult
            .values()
            .handleEvents(receiveOutput: { [analyticsManager, widgetManager] in
                analyticsManager.logEvent(eventName: AnalyticsEventConst.editPositiveStatment)
                widgetManager.reloadPositiveStatementWidget()
            })
            .sink { [router] in
                router?.dismiss()
            }
            .store(in: &cancellable)

        editPositiveStatementResult
            .errors()
            .map { _ in
                AlertItem(title: R.string.localizable.edit_positive_statement_edit_error(), message: nil)
            }
            .assign(to: &outputs.$showAlert)
    }
}

extension EditPositiveStatementViewModel {
    class Inputs {
        let onAppear = PassthroughSubject<Void, Never>()
        let textFieldTextDidChange = PassthroughSubject<String, Never>()
        let cancelButtonDidTap = PassthroughSubject<Void, Never>()
        let doneButtonDidTap = PassthroughSubject<Void, Never>()
        let scrollViewOffsetDidChange = CurrentValueSubject<CGFloat, Never>(0)
    }

    class Outputs: ObservableObject {
        let closeKeyboard = PassthroughSubject<Void, Never>()
        let characterCounterText = CurrentValueSubject<String, Never>("")
        let characterCounterColor = CurrentValueSubject<ThemeColor, Never>(.text)
        let isDoneButtonDisabled = CurrentValueSubject<Bool, Never>(true)
        @Published var navigationBarTitle = ""
        @Published var isProcessing = false
        @Published var showAlert: AlertItem?
    }

    class Bindings: ObservableObject {
        @Published var textFieldText = ""
    }
}
