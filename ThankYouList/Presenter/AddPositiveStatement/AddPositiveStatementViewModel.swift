//
//  AddPositiveStatementViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/03/06.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine

private let positiveStatementMaxCount = 100

class AddPositiveStatementViewModel: ObservableObject {

    let inputs = Inputs()
    let outputs = Outputs()
    @Published var bindings = Bindings()

    private var cancellable = Set<AnyCancellable>()

    init() {
        bind()
    }
}

private extension AddPositiveStatementViewModel {
    func bind() {
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
    }
}

extension AddPositiveStatementViewModel {
    class Inputs {
        let textFieldTextDidChange = PassthroughSubject<String, Never>()
    }

    class Outputs {
        let closeKeyboard = PassthroughSubject<Void, Never>()
        let characterCounterText = CurrentValueSubject<String, Never>("")
    }

    class Bindings: ObservableObject {
        @Published var textFieldText = ""
    }
}
