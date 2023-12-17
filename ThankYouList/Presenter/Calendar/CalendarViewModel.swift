//
//  CalendarViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/09/03.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Foundation
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
            .merge(with: inputs.calendarDidSelectDate
                .handleEvents(receiveOutput: { [weak self] date in
                    self?.inMemoryDataStore.selectedDate = date
                }))
            .subscribe(outputs.currentSelectedDate)
            .store(in: &cancellables)
    }
}

extension CalendarViewModel {
    class Inputs {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let calendarDidScrollToMonth = PassthroughSubject<Date, Never>()
        let calendarDidSelectDate = PassthroughSubject<Date, Never>()
    }

    class Outputs {
        let currentSelectedDate = CurrentValueSubject<Date, Never>(Date())
    }
}

private extension CalendarConfiguration {
    static func createWith2YearsRange(baseDate: Date) -> CalendarConfiguration? {
        let calendar = Calendar(identifier: .gregorian)
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: baseDate),
              let oneYearLater = calendar.date(byAdding: .year, value: 1, to: baseDate) else {
            return nil
        }
        return CalendarConfiguration(startDate: oneYearAgo,
                                     endDate: oneYearLater,
                                     calendar: calendar)
    }
}
