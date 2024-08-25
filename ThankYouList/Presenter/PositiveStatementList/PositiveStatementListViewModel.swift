//
//  PositiveStatementListViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/01/21.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import CombineSchedulers
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
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(
        userRepository: UserRepository,
        positiveStatementRepository: PositiveStatementRepository,
        router: PositiveStatementListRouter?,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.userRepository = userRepository
        self.positiveStatementRepository = positiveStatementRepository
        self.router = router
        self.scheduler = scheduler
        bind()
    }

    deinit {
        cancellable.removeAll()
    }
}

private extension PositiveStatementListViewModel {
    func bind() {
        let profile = inputs.onAppear
            .first()
            .flatMap { [userRepository] in
                userRepository.getUserProfile()
            }
            .shareReplay(1)

        let positiveStatements = profile
            .flatMap { [positiveStatementRepository] profile in
                positiveStatementRepository.subscribePositiveStatements(userId: profile.id)
            }
            .asResult()
            .share()

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

        inputs.positiveStatementMenuButtonDidTap
            .map { _ in PositiveStatementTapMenu.allCases }
            .assign(to: &outputs.$bottomMenuList)

        Publishers
            .Merge(
                inputs.positiveStatementMenuButtonDidTap.map { _ in true },
                inputs.bottomMenuDidTap.map { _ in false }
            )
            .assign(to: &outputs.$showBottomMenu)

        let bottomMenuDidTap = inputs.bottomMenuDidTap
            .withLatestFrom(inputs.positiveStatementMenuButtonDidTap) { ($0, $1) }
            .share()

        let confirmDeleteButtonDidTap = PassthroughSubject<String, Never>()

        bottomMenuDidTap
            .filter { menuType, _ in menuType == .delete }
            .flatMap { [outputs, scheduler] menuInfo in
                // Wait until bottom menu gets hidden, otherwise the alert won't be shown
                outputs.$showBottomMenu.filter { !$0 }.first().map { _ in menuInfo }
                    .delay(for: .milliseconds(10), scheduler: scheduler)
            }
            .map { _, positiveStatementId in
                let deleteAction = AlertAction(title: R.string.localizable.delete(),
                                               style: .destructive) {
                    confirmDeleteButtonDidTap.send(positiveStatementId)
                }
                let cancelAction = AlertAction(title: R.string.localizable.cancel(),
                                               style: .cancel)
                return AlertItem(
                    title: R.string.localizable.positive_statement_list_confirm_delete_title(),
                    message: R.string.localizable.positive_statement_list_confirm_delete_message(),
                    primaryAction: deleteAction,
                    secondaryAction: cancelAction
                )
            }
            .assign(to: &outputs.$showAlert)

        let deleteResult = confirmDeleteButtonDidTap
            .withLatestFrom(profile.catch { _ in Empty<Profile, Never>() }) { ($0, $1) }
            .flatMap { [positiveStatementRepository] positiveStatementId, profile in
                return positiveStatementRepository
                    .deletePositiveStatement(
                        positiveStatementId: positiveStatementId,
                        userId: profile.id)
                    .asResult()
            }
            .share()

        deleteResult
            .values()
            .sink { _ in }
            .store(in: &cancellable)

        deleteResult
            .errors()
            .map { _ in
                AlertItem(title: R.string.localizable.failedToDelete(), message: nil)
            }
            .receive(on: scheduler)
            .assign(to: &outputs.$showAlert)
    }
}

extension PositiveStatementListViewModel {
    class Inputs {
        let onAppear = PassthroughSubject<Void, Never>()
        let addButtonDidTap = PassthroughSubject<Void, Never>()
        let widgetHintButtonDidTap = PassthroughSubject<Void, Never>()
        let positiveStatementMenuButtonDidTap = PassthroughSubject<String, Never>()
        let bottomMenuDidTap = PassthroughSubject<PositiveStatementTapMenu, Never>()
    }

    class Outputs: ObservableObject {
        @Published var positiveStatements = [PositiveStatementModel]()
        @Published var isAddButtonDisabled = true
        @Published var showBottomMenu = false
        @Published var bottomMenuList = [PositiveStatementTapMenu]()
        @Published var showAlert: AlertItem?
    }
}
