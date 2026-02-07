//
//  ThankYouListViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2026/01/20.
//  Copyright © 2026 Aika Yamada. All rights reserved.
//

import Combine
import CombineSchedulers
import Foundation

protocol ThankYouListRouter: Router {
    func presentMyPage()
    func presentEditThankYou(thankYouId: String)
}

class ThankYouListViewModel: ObservableObject {

    let inputs = Inputs()
    let outputs = Outputs()

    private var cancellables = Set<AnyCancellable>()
    private let userRepository: UserRepository
    private let thankYouRepository: ThankYouRepository
    private let router: ThankYouListRouter?
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(
        userRepository: UserRepository,
        thankYouRepository: ThankYouRepository,
        router: ThankYouListRouter,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.userRepository = userRepository
        self.thankYouRepository = thankYouRepository
        self.router = router
        self.scheduler = scheduler
        bind()
    }
}

private extension ThankYouListViewModel {
    func bind() {
        bindCardTapAction()

        inputs.viewDidLoad
            .flatMap { [userRepository] in
                userRepository.getUserProfile().map(\.id)
            }
            .flatMap { [thankYouRepository] userId in
                thankYouRepository.subscribeThankYouList(userId: userId)
            }
            .catch { error in Just(.error(error)) }
            .scan([ThankYouListViewController.ListSection]()) { [weak self] list, result in
                var newList = list
                switch result {
                case .error:
                    self?.router?.presentAlert(
                        title: R.string.localizable.thank_you_list_load_error_title(),
                        message: R.string.localizable.thank_you_list_load_error_message()
                    )
                default: break
                }
                return newList
            }
            .subscribe(outputs.listSections)
            .store(in: &cancellables)

        inputs.userIconDidTap
            .receive(on: scheduler)
            .sink { [router] in
                router?.presentMyPage()
            }
            .store(in: &cancellables)
    }

    func bindCardTapAction() {
        let didTapMenu = inputs.bottomHalfSheetMenuDidTap
            .compactMap { menuItem -> (menu: ThankYouCellTapMenu, thankYouId: String)? in
                guard let itemRawValue = menuItem.rawValue,
                      let cellMenu = ThankYouCellTapMenu(rawValue: itemRawValue),
                      let thankYouId = menuItem.id else {
                    return nil
                }
                return (menu: cellMenu, thankYouId: thankYouId)
            }
            .sendEvent((), to: outputs.dismissPresentedView)
            .share()

        didTapMenu
            .filter { $0.menu == .edit }
            .receive(on: scheduler)
            .sink { [router] in
                router?.presentEditThankYou(thankYouId: $0.thankYouId)
            }
            .store(in: &cancellables)

        let deleteAction = PassthroughSubject<String, Never>()

        didTapMenu
            .filter { $0.menu == .delete }
            .receive(on: scheduler)
            .sink { [router] menuItem in
                let deleteAction = AlertAction(title: R.string.localizable.delete(),
                                               style: .destructive) {
                    deleteAction.send(menuItem.thankYouId)
                }
                let cancelAction = AlertAction(title: R.string.localizable.cancel(),
                                               style: .cancel)
                router?.presentAlert(
                    title: R.string.localizable.deleteThankYou(),
                    message: R.string.localizable.areYouSureYouWantToDeleteThisThankYou(),
                    actions: [deleteAction, cancelAction]
                )
            }
            .store(in: &cancellables)

        let deleteResult = deleteAction
            .flatMap { [userRepository, thankYouRepository] thankYouId in
                userRepository.getUserProfile()
                    .flatMap { [thankYouRepository] profile in
                        let deletingThankYou = thankYouRepository.loadThankYou(thankYouId: thankYouId)
                        return thankYouRepository.deleteThankYou(
                            thankYouId: thankYouId,
                            userId: profile.id)
                        .map { _ in deletingThankYou }
                    }
                    .asResult()
            }
            .eraseToAnyPublisher()
            .share()

        deleteResult
            .values()
            .sink { _ in }
            .store(in: &cancellables)
    }
}

extension ThankYouListViewModel {
    class Inputs {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let userIconDidTap = PassthroughSubject<Void, Never>()
        let bottomHalfSheetMenuDidTap = PassthroughSubject<BottomHalfSheetMenuItem, Never>()
    }

    class Outputs {
        let listSections = CurrentValueSubject<[ThankYouListViewController.ListSection], Never>([])
        let dismissPresentedView = PassthroughSubject<Void, Never>()
    }
}
