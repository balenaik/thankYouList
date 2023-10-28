//
//  CalendarViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/09/03.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Combine

class CalendarViewModel: ObservableObject {

    let inputs = Inputs()
    let outputs = Outputs()

    private var cancellables = Set<AnyCancellable>()
    private var inMemoryDataStore: InMemoryDataStore

    init(inMemoryDataStore: InMemoryDataStore = DefaultInMemoryDataStore.shared) {
        self.inMemoryDataStore = inMemoryDataStore
        bind()
    }
}

private extension CalendarViewModel {
    func bind() {
        inputs.viewDidLoad
            .compactMap { [weak self] in self?.inMemoryDataStore.selectedDate }
            .subscribe(outputs.currentSelectedDate)
            .store(in: &cancellables)
    }
}

extension CalendarViewModel {
    class Inputs {
        let viewDidLoad = PassthroughSubject<Void, Never>()
    }

    class Outputs {
        let currentSelectedDate = CurrentValueSubject<Date, Never>(Date())
    }
}
