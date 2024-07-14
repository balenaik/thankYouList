//
//  PositiveStatementListViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/01/21.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import Foundation

protocol PositiveStatementListRouter: Router {
    func popToPreviousScreen()
    func presentAddPositiveStatement()
}

class PositiveStatementListViewModel: ObservableObject {

    let inputs = Inputs()
    let outputs = Outputs()

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
            .subscribe(outputs.positiveStatements)
            .store(in: &cancellable)

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

        inputs.addButtonDidTap
            .sink { [router] in
                router?.presentAddPositiveStatement()
            }
            .store(in: &cancellable)
    }
}

extension PositiveStatementListViewModel {
    class Inputs {
        let onAppear = PassthroughSubject<Void, Never>()
        let addButtonDidTap = PassthroughSubject<Void, Never>()
    }

    class Outputs {
        let positiveStatements = CurrentValueSubject<[PositiveStatementModel], Never>([])
    }
}
