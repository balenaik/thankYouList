//
//  CalendarViewModelTests.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2023/10/08.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import XCTest
import Combine
import CombineSchedulers
@testable import ThankYouList

final class CalendarViewModelTests: XCTestCase {

    private var viewModel: CalendarViewModel!
    private var inMemoryDataStore: InMemoryDataStore!

    private var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        inMemoryDataStore = MockInMemoryDataStore()
        scheduler = DispatchQueue.test
        viewModel = CalendarViewModel(inMemoryDataStore: inMemoryDataStore,
                                      scheduler: scheduler.eraseToAnyScheduler())
    }

    func test_ifTheUserScrollsCalendar__itShouldOutputCalendarConfiguration_with2YearsRange_andReconfigureCalendarDataSource() throws {

        let calendarConfigurationRecords = TestRecord(
            publisher: viewModel.outputs.calendarConfiguration.eraseToAnyPublisher())

        let reconfigureCalendarDataSourceRecords = TestRecord(
            publisher: viewModel.outputs.reconfigureCalendarDataSource.eraseToAnyPublisher())

        let calendar = Calendar(identifier: .gregorian)
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2020, month: 3, day: 15)))

        // scroll to a date
        viewModel.inputs.calendarDidScrollToMonth.send(date)

        let oneYearBeforeDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2019, month: 3, day: 15)))
        let oneYearAfterDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2021, month: 3, day: 15)))

        scheduler.advance(by: .milliseconds(100))

        calendarConfigurationRecords.results.removeFirst() // Remove the first event when subscribed (Cannot be asserted)
        XCTAssertEqual(calendarConfigurationRecords.results, [
            .value(.init(startDate: oneYearBeforeDate,
                         endDate: oneYearAfterDate,
                         calendar: calendar))
        ])
        XCTAssertEqual(reconfigureCalendarDataSourceRecords.results, [
            .value(date)
        ])
    }
}
