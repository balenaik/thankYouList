//
//  AddPositiveStatementViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/03/06.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import Foundation

private let positiveStatementMaxCount = 100

protocol AddPositiveStatementRouter: Router {
    func dismiss()
}

class AddPositiveStatementViewModel: ObservableObject {

    let inputs = Inputs()
    let outputs = Outputs()
    @Published var bindings = Bindings()

    private var cancellable = Set<AnyCancellable>()
    private let userRepository: UserRepository
    private let positiveStatementRepository: PositiveStatementRepository
    private let router: AddPositiveStatementRouter?

    init(userRepository: UserRepository,
         positiveStatementRepository: PositiveStatementRepository,
         router: AddPositiveStatementRouter?) {
        self.router = router
        self.userRepository = userRepository
        self.positiveStatementRepository = positiveStatementRepository
        bind()
    }
}

private extension AddPositiveStatementViewModel {
    func bind() {
        inputs.scrollViewOffsetDidChange
            .map {
                $0 > ViewConst.swiftUINavigationTitleVisibleOffset
                ? R.string.localizable.add_positive_statement_title()
                : ""
            }
            .removeDuplicates()
            .assign(to: &outputs.$navigationBarTitle)

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
                    .add_positive_statement_character_count_text(
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
            .map { $0.isEmpty || $0.count > positiveStatementMaxCount }
            .subscribe(outputs.isDoneButtonDisabled)
            .store(in: &cancellable)

        inputs.cancelButtonDidTap
            .sink { [router] in router?.dismiss() }
            .store(in: &cancellable)

        inputs.doneButtonDidTap
            .subscribe(outputs.closeKeyboard)
            .store(in: &cancellable)

        inputs.doneButtonDidTap
            .handleEvents(receiveOutput: { [outputs] in outputs.isProcessing = true })
            .map { [bindings] in bindings.textFieldText }
            .setFailureType(to: Error.self)
            .flatMap { [userRepository, positiveStatementRepository] positiveStatement in
                userRepository.getUserProfile().map { ($0, positiveStatement) }
                    .flatMap { [positiveStatementRepository] userProfile, positiveStatement in
                        positiveStatementRepository
                            .createPositiveStatement(
                                positiveStatement: positiveStatement,
                                userId: userProfile.id)
                    }
                    .asResult()
            }
            .handleEvents(receiveOutput: { [outputs] _ in outputs.isProcessing = false })
            .sink(receiveCompletion: { _ in }, receiveValue: { [router] result in
                switch result {
                case .success:
                    router?.dismiss()
                case .failure:
                    router?.presentAlert(title: R.string.localizable.add_positive_statement_add_error())
                }
            })
            .store(in: &cancellable)
    }
}

extension AddPositiveStatementViewModel {
    class Inputs {
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
    }

    class Bindings: ObservableObject {
        @Published var textFieldText = ""
    }
}
