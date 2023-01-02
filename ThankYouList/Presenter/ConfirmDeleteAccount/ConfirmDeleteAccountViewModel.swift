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

    @Published var emailAddress = ""
    private var cancellable = Set<AnyCancellable>()

    init() {
        bind()
    }
}

private extension ConfirmDeleteAccountViewModel {
    func bind() {
        inputs.cancelButtonDidTap
            .sink { [weak self] _ in
                self?.outputs.dismissView.send(())
            }
            .store(in: &cancellable)
    }
}

extension ConfirmDeleteAccountViewModel {
    struct Inputs {
        let cancelButtonDidTap = PassthroughSubject<Void, Never>()
    }

    struct Outputs {
        let dismissView = PassthroughSubject<Void, Never>()
    }
}
