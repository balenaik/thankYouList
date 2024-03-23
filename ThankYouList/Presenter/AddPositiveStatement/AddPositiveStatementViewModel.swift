//
//  AddPositiveStatementViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/03/06.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine

class AddPositiveStatementViewModel: ObservableObject {

    let inputs = Inputs()
    let outputs = Outputs()
    @Published var bindings = Bindings()

    private var cancellable = Set<AnyCancellable>()

    init() {
        bind()
    }
}

private extension AddPositiveStatementViewModel {
    func bind() {
        bindings.$textFieldText
            .sink { aaa in
                debugPrint(aaa)
            }
            .store(in: &cancellable)
    }
}

extension AddPositiveStatementViewModel {
    class Inputs {
    }

    class Outputs {
        let closeKeyboard = PassthroughSubject<Void, Never>()
    }

    class Bindings: ObservableObject {
        @Published var textFieldText = ""
    }
}
