//
//  PositiveStatementListViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/01/21.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import Foundation

private let maxPositiveStatementCount = 10

protocol PositiveStatementListRouter: Router {
    func popToPreviousScreen()
    func presentAddPositiveStatement()
    func presentHomeWidgetInstruction()
}

class PositiveStatementListViewModel: ObservableObject {

    let inputs = Inputs()
    @Published var outputs = Outputs()

    private var cancellable = Set<AnyCancellable>()
    private let userRepository: UserRepository
    private let positiveStatementRepository: PositiveStatementRepository
    private let router: PositiveStatementListRouter?
    
    init(
        userRepository: UserRepository,
        positiveStatementRepository: PositiveStatementRepository,
        router: PositiveStatementListRouter?
    ) {
        self.userRepository = userRepository
        self.positiveStatementRepository = positiveStatementRepository
        self.router = router
        bind()
    }

    deinit {
        cancellable.removeAll()
    }
}

private extension PositiveStatementListViewModel {
    func bind() {
        let positiveStatements = inputs.onAppear
            .first()
            .flatMap { [userRepository] in
                userRepository.getUserProfile()
            }
            .flatMap { [positiveStatementRepository] profile in
                positiveStatementRepository.subscribePositiveStatements(userId: profile.id)
            }
            .asResult()
            .share()
            .eraseToAnyPublisher()

        positiveStatements
            .values()
            .assign(to: &outputs.$positiveStatements)

        positiveStatements
            .errors()
            .sink { [router] _ in
                router?.presentAlert(
                    title: R.string.localizable.something_went_wrong_title(),
                    message: R.string.localizable.positive_statement_list_error_message(),
                    actions: [.init(
                        title: R.string.localizable.ok(),
                        action: {
                            router?.popToPreviousScreen()
                        })
                    ])
            }
            .store(in: &cancellable)

        positiveStatements
            .values()
            .map { $0.count >= maxPositiveStatementCount }
            .assign(to: &outputs.$isAddButtonDisabled)

        inputs.addButtonDidTap
            .sink { [router] in
                router?.presentAddPositiveStatement()
            }
            .store(in: &cancellable)

        inputs.widgetHintButtonDidTap
            .sink { [router] in
                router?.presentHomeWidgetInstruction()
            }
            .store(in: &cancellable)
    }
}

extension PositiveStatementListViewModel {
    class Inputs {
        let onAppear = PassthroughSubject<Void, Never>()
        let addButtonDidTap = PassthroughSubject<Void, Never>()
        let widgetHintButtonDidTap = PassthroughSubject<Void, Never>()
        let positiveStatementMenuButtonDidTap = PassthroughSubject<String, Never>()
    }

    class Outputs: ObservableObject {
        @Published var positiveStatements = [PositiveStatementModel]()
        @Published var isAddButtonDisabled = true
    }
}
