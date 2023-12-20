//
//  CalendarViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/09/03.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Foundation
import Combine
import CombineSchedulers

class CalendarViewModel: ObservableObject {

    let inputs = Inputs()
    let outputs = Outputs()

    private var cancellables = Set<AnyCancellable>()
    private var inMemoryDataStore: InMemoryDataStore
    private let userRepository: UserRepository
    private let analyticsManager: AnalyticsManager
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(inMemoryDataStore: InMemoryDataStore = DefaultInMemoryDataStore.shared,
         userRepository: UserRepository,
         analyticsManager: AnalyticsManager,
         scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        self.inMemoryDataStore = inMemoryDataStore
        self.userRepository = userRepository
        self.analyticsManager = analyticsManager
        self.scheduler = scheduler
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

        outputs.currentSelectedDate
            .map { _ in }
            .subscribe(outputs.reloadCurrentVisibleCalendar)
            .store(in: &cancellables)

        inputs.calendarDidScrollToMonth
            .compactMap { newDate in
                CalendarConfiguration.createWith2YearsRange(baseDate: newDate)
            }
            .delay(for: .milliseconds(100), scheduler: scheduler)
            .subscribe(outputs.calendarConfiguration)
            .store(in: &cancellables)

        outputs.calendarConfiguration
            .withLatestFrom(inputs.calendarDidScrollToMonth) { $1 }
            .subscribe(outputs.reconfigureCalendarDataSource)
            .store(in: &cancellables)

        inputs.calendarDidScrollToMonth
            .setFailureType(to: Error.self)
            .flatMap { [userRepository] newDate in
                userRepository.getUserProfile()
                    .map { ($0.id, newDate) }
            }
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [analyticsManager] userId, newDate in
                analyticsManager.logEvent(eventName: AnalyticsEventConst.scrollCalendar,
                                          userId: userId,
                                          targetDate: newDate)
            })
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
        let calendarConfiguration = CurrentValueSubject<CalendarConfiguration?, Never>(CalendarConfiguration.createWith2YearsRange(baseDate: Date()))
        let currentSelectedDate = CurrentValueSubject<Date, Never>(Date())
        let reconfigureCalendarDataSource = PassthroughSubject<Date, Never>()
        let reloadCurrentVisibleCalendar = PassthroughSubject<Void, Never>()
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
