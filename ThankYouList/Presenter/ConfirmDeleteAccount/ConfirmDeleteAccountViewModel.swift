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
        let outputs = outputs

        let email = Just(())
            .map { [userRepository] _ in
                userRepository.getUserProfile().map { $0.email }
            }
            .shareReplay(1)

        email
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .subscribe(outputs.emailTextFieldPlaceHolder)
            .store(in: &cancellable)

        email
            .filter { $0 == nil || $0?.isEmpty ?? true }
            .map { _ in AlertItem(
                title: R.string.localizable.confirm_delete_account_error_title(),
                message: R.string.localizable.confirm_delete_account_error_message(),
                okAction: { outputs.dismissView.send(()) })
            }
            .assign(to: \.alertItem, on: bindings)
            .store(in: &cancellable)

        inputs.cancelButtonDidTap
            .subscribe(outputs.dismissView)
            .store(in: &cancellable)

        inputs.deleteAccountButtonDidTap
            .flatMap { email }
            .compactMap { $0 }
            .withLatestFrom(bindings.$emailTextFieldText) { ($0, $1) }
            .filter { $0.0.lowercased() != $0.1.lowercased() }
            .map { registeredEmail, _ in AlertItem(
                title: R.string.localizable.confirm_delete_account_email_not_match_title(),
                message: R.string.localizable.confirm_delete_account_email_not_match_message(registeredEmail))
            }
            .assign(to: \.alertItem, on: bindings)
            .store(in: &cancellable)

        bindings.$emailTextFieldText
            .map { !$0.isValidMail }
            .assign(to: &outputs.$isDeleteAccountButtonDisabled)
    }
}

extension ConfirmDeleteAccountViewModel {
    class Inputs {
        let cancelButtonDidTap = PassthroughSubject<Void, Never>()
        let deleteAccountButtonDidTap = PassthroughSubject<Void, Never>()
    }

    class Outputs {
        let emailTextFieldPlaceHolder = CurrentValueSubject<String, Never>("")
        let dismissView = PassthroughSubject<Void, Never>()
        @Published var isDeleteAccountButtonDisabled = true
    }

    class Bindings: ObservableObject {
        @Published var emailTextFieldText = ""
        @Published var alertItem: AlertItem?
    }
}
