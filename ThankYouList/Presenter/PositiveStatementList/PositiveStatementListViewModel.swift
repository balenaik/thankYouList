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
    }
}

extension PositiveStatementListViewModel {
    class Inputs {
        let onAppear = PassthroughSubject<Void, Never>()
    }

    class Outputs {
        let positiveStatements = CurrentValueSubject<[PositiveStatementModel], Never>([])
    }
}
