//
//  ConfirmDeleteAccountViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2022/12/28.
//  Copyright © 2022 Aika Yamada. All rights reserved.
//

import Combine

class ConfirmDeleteAccountViewModel: ObservableObject {

    let inputs = Inputs()
    let outputs = Outputs()
    @Published var bindings = Bindings()

    private var cancellable = Set<AnyCancellable>()
    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
        bind()
    }
}

private extension ConfirmDeleteAccountViewModel {
    func bind() {
        let email = Just(())
            .map { [userRepository] _ in
                userRepository.getUserProfile().map { $0.email }
            }

        email
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .subscribe(outputs.emailTextFieldPlaceHolder)
            .store(in: &cancellable)

        inputs.cancelButtonDidTap
            .sink { [weak self] _ in
                self?.outputs.dismissView.send(())
            }
            .store(in: &cancellable)

        bindings.$emailTextFieldText
            .map { !$0.isValidMail }
            .assign(to: &outputs.$isDeleteAccountButtonDisabled)
    }
}

extension ConfirmDeleteAccountViewModel {
    class Inputs {
        let cancelButtonDidTap = PassthroughSubject<Void, Never>()
    }

    class Outputs {
        let emailTextFieldPlaceHolder = CurrentValueSubject<String, Never>("")
        let dismissView = PassthroughSubject<Void, Never>()
        @Published var isDeleteAccountButtonDisabled = true
    }

    class Bindings {
        @Published var emailTextFieldText = ""
    }
}
