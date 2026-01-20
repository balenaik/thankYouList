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
        inputs.userIconDidTap
            .receive(on: scheduler)
            .sink { [router] in
                router?.presentMyPage()
            }
            .store(in: &cancellables)
    }
}

extension ThankYouListViewModel {
    class Inputs {
        let userIconDidTap = PassthroughSubject<Void, Never>()
    }

    class Outputs {
    }
}
