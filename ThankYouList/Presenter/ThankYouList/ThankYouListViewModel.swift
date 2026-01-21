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

class ThankYouListViewModel: ObservableObject {

    let inputs = Inputs()
    let outputs = Outputs()

    private var cancellables = Set<AnyCancellable>()
    private let router: ThankYouListRouter?
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(router: ThankYouListRouter,
         scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        self.router = router
        self.scheduler = scheduler
        bind()
    }
}

private extension ThankYouListViewModel {
    func bind() {
        bindCardTapAction()
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
    }
}

extension ThankYouListViewModel {
    class Inputs {
        let userIconDidTap = PassthroughSubject<Void, Never>()
        let bottomHalfSheetMenuDidTap = PassthroughSubject<BottomHalfSheetMenuItem, Never>()
    }

    class Outputs {
        let dismissPresentedView = PassthroughSubject<Void, Never>()
    }
}
