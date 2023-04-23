//
//  ConfirmDeleteAccountViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2022/12/28.
//  Copyright © 2022 Aika Yamada. All rights reserved.
//

import Combine

protocol ConfirmDeleteAccountRouter: Router {
    func dismiss()
    func switchToLogin()
}

class ConfirmDeleteAccountViewModel: ObservableObject {

    let inputs = Inputs()
    let outputs = Outputs()
    @Published var bindings = Bindings()

    private var cancellable = Set<AnyCancellable>()
    private let userRepository: UserRepository
    private let router: ConfirmDeleteAccountRouter?

    init(userRepository: UserRepository,
         router: ConfirmDeleteAccountRouter?) {
        self.userRepository = userRepository
        self.router = router
        bind()
    }
}

private extension ConfirmDeleteAccountViewModel {
    func bind() {
        let router = router

        let profile = Just(())
            .merge(with: inputs.onAppear)
            .flatMap { [userRepository] _ in
                userRepository.getUserProfile()
            }
            .asResult()
            .eraseToAnyPublisher()
            .shareReplay(1)

        profile
            .values()
            .map(\.email)
            .filter { !$0.isEmpty }
            .subscribe(outputs.emailTextFieldPlaceHolder)
            .store(in: &cancellable)

        profile.values()
            .map(\.email).filter { $0.isEmpty }.map { _ in }
            .merge(with: profile.errors().map { _ in })
            .map { _ in AlertItem(
                title: R.string.localizable.confirm_delete_account_error_title(),
                message: R.string.localizable.confirm_delete_account_error_message(),
                okAction: { router?.dismiss() })
            }
            .assign(to: \.alertItem, on: bindings)
            .store(in: &cancellable)

        inputs.cancelButtonDidTap
            .sink { router?.dismiss() }
            .store(in: &cancellable)

        let textFieldMatchesEmailResult = inputs.deleteAccountButtonDidTap
            .flatMap { profile.values() }
            .compactMap { $0.email }
            .withLatestFrom(bindings.$emailTextFieldText) { ($0, $1) }
            .map { $0.0.lowercased() == $0.1.lowercased() }
            .share()

        textFieldMatchesEmailResult
            .filter { !$0 }
            .flatMap { _ in profile.values() }
            .compactMap { $0.email }
            .map { registeredEmail in AlertItem(
                title: R.string.localizable.confirm_delete_account_email_not_match_title(),
                message: R.string.localizable.confirm_delete_account_email_not_match_message(registeredEmail))
            }
            .assign(to: \.alertItem, on: bindings)
            .store(in: &cancellable)

        let deleteAccountResult = textFieldMatchesEmailResult
            .filter { $0 }
            .flatMap { [userRepository] _ -> AnyPublisher<Result<Void, Error>, Never> in
                userRepository.deleteAccount().asResult()
            }
            .share()

        deleteAccountResult
            .values()
            .map { _ in
                AlertItem(title: R.string.localizable.confirm_delete_account_completed_title(),
                          message: nil) {
                    router?.switchToLogin()
                }
            }
            .assign(to: \.alertItem, on: bindings)
            .store(in: &cancellable)

        deleteAccountResult
            .errors()
            .map { _ in AlertItem(title: R.string.localizable.confirm_delete_account_error_title(),
                                  message: R.string.localizable.try_again_later_message()) }
            .assign(to: \.alertItem, on: bindings)
            .store(in: &cancellable)

        bindings.$emailTextFieldText
            .map { !$0.isValidMail }
            .assign(to: &outputs.$isDeleteAccountButtonDisabled)
    }
}

extension ConfirmDeleteAccountViewModel {
    class Inputs {
        let onAppear = PassthroughSubject<Void, Never>() // Only for testing purpose
        let cancelButtonDidTap = PassthroughSubject<Void, Never>()
        let deleteAccountButtonDidTap = PassthroughSubject<Void, Never>()
    }

    class Outputs {
        let emailTextFieldPlaceHolder = CurrentValueSubject<String, Never>("")
        @Published var isDeleteAccountButtonDisabled = true
    }

    class Bindings: ObservableObject {
        @Published var emailTextFieldText = ""
        @Published var alertItem: AlertItem?
    }
}
