//
//  EditPositiveStatementViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/08/25.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import Foundation

private let positiveStatementMaxCount = 100

protocol EditPositiveStatementRouter: Router {
    func dismiss()
}

class EditPositiveStatementViewModel: ObservableObject {

    let inputs = Inputs()
    let outputs = Outputs()
    @Published var bindings = Bindings()

    private var cancellable = Set<AnyCancellable>()
    private let userRepository: UserRepository
    private let positiveStatementRepository: PositiveStatementRepository
    private let router: EditPositiveStatementRouter?

    init(userRepository: UserRepository,
         positiveStatementRepository: PositiveStatementRepository,
         router: EditPositiveStatementRouter?) {
        self.router = router
        self.userRepository = userRepository
        self.positiveStatementRepository = positiveStatementRepository
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

        inputs.cancelButtonDidTap
            .sink { [router] in router?.dismiss() }
            .store(in: &cancellable)
    }
}

extension EditPositiveStatementViewModel {
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
