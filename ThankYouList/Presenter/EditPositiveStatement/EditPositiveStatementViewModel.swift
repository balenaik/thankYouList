//
//  EditPositiveStatementViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/08/25.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine

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
    }
}

extension EditPositiveStatementViewModel {
    class Inputs {
        let textFieldTextDidChange = PassthroughSubject<String, Never>()
        let cancelButtonDidTap = PassthroughSubject<Void, Never>()
        let doneButtonDidTap = PassthroughSubject<Void, Never>()
    }

    class Outputs {
        let closeKeyboard = PassthroughSubject<Void, Never>()
        let characterCounterText = CurrentValueSubject<String, Never>("")
        let characterCounterColor = CurrentValueSubject<ThemeColor, Never>(.text)
        let isDoneButtonDisabled = CurrentValueSubject<Bool, Never>(true)
    }

    class Bindings: ObservableObject {
        @Published var textFieldText = ""
        @Published var isProcessing = false
    }
}
