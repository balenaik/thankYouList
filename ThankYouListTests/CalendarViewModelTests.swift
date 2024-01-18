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
    private var userRepository: MockUserRepository!
    private var thankYouRepository: MockThankYouRepository!
    private var analyticsManager: MockAnalyticsManager!
    private var router: MockCalendarRouter!

    private var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        inMemoryDataStore = MockInMemoryDataStore()
        userRepository = MockUserRepository()
        thankYouRepository = MockThankYouRepository()
        analyticsManager = MockAnalyticsManager()
        router = MockCalendarRouter()
        scheduler = DispatchQueue.test
        viewModel = CalendarViewModel(inMemoryDataStore: inMemoryDataStore,
                                      userRepository: userRepository,
                                      thankYouRepository: thankYouRepository,
                                      analyticsManager: analyticsManager,
                                      router: router,
                                      scheduler: scheduler.eraseToAnyScheduler())
    }

    func test_ifTheUserOpensTheScreen__itShouldOutputTheSelectedDateAsCurrentSelectedDate_andReloadCurrentVisibleCalendar() {
        let date = Date(timeIntervalSince1970: 12345)
        inMemoryDataStore.selectedDate = date

        let currentSelectedDateRecords = TestRecord(
            publisher: viewModel.outputs.currentSelectedDate.eraseToAnyPublisher())

        let reloadCurrentVisibleCalendarRecords = TestRecord(
            publisher: viewModel.outputs.reloadCurrentVisibleCalendar.map { "" }.eraseToAnyPublisher()) // Void cannot be compared

        // Opens screen
        viewModel.inputs.viewDidLoad.send()

        // index 0 should be the time when this Subject is created, which cannot be tested, so remove it beforehand
        currentSelectedDateRecords.results.removeFirst()
        XCTAssertEqual(currentSelectedDateRecords.results, [
            (.value(date))
        ])
        XCTAssertEqual(reloadCurrentVisibleCalendarRecords.results, [
            (.value("")),
            (.value(""))
        ])
    }

    func test_ifTheUserTapsDateFromCalendar__itShouldUpdateInMemoryDataStore_andOutputTheDateAsCurrentSelectedDate_andReloadCurrentVisibleCalendar() {
        inMemoryDataStore.selectedDate = Date(timeIntervalSince1970: 12345)

        let currentSelectedDateRecords = TestRecord(
            publisher: viewModel.outputs.currentSelectedDate.eraseToAnyPublisher())

        let reloadCurrentVisibleCalendarRecords = TestRecord(
            publisher: viewModel.outputs.reloadCurrentVisibleCalendar.map { "" }.eraseToAnyPublisher()) // Void cannot be compared

        let tappedDate = Date(timeIntervalSince1970: 67890)

        // Taps date
        viewModel.inputs.calendarDidSelectDate.send(tappedDate)

        // Should update InMemoryDataStore
        XCTAssertEqual(inMemoryDataStore.selectedDate, tappedDate)

        // index 1 should be the time when this Subject is created, which cannot be tested, so remove it beforehand
        currentSelectedDateRecords.results.removeFirst()
        XCTAssertEqual(currentSelectedDateRecords.results, [
            (.value(tappedDate))
        ])
        XCTAssertEqual(reloadCurrentVisibleCalendarRecords.results, [
            .value(""),
            .value("")
        ])
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

    func test_ifUserScrollsCalendar__itShouldSendAnalyticsEvent_withUserId_andTheScrolledDate() {
        let userId = "userId"
        userRepository.getUserProfile_result = Just(Profile(id: userId, name: "", email: "", imageUrl: nil)).setFailureType(to: Error.self).asFuture()

        // Scrolls calendar
        let date = Date(timeIntervalSince1970: 1234566)
        viewModel.inputs.calendarDidScrollToMonth.send(date)

        XCTAssertEqual(analyticsManager.loggedEvent.count, 1)
        XCTAssertEqual(analyticsManager.loggedEvent.first?.eventName, AnalyticsEventConst.scrollCalendar)
        XCTAssertEqual(analyticsManager.loggedEvent.first?.userId, userId)
        XCTAssertEqual(analyticsManager.loggedEvent.first?.targetDate, date)
    }

    func test_ifUserTapsUserIcon__itShouldShowMyPage() {
        viewModel.inputs.userIconDidTap.send()
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(router.presentMyPage_calledCount, 1)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasNilRawValue__itShouldNotEitherPresentEditThankYouOrPresentAlert() {
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "", image: nil, rawValue: nil, id: "123")
        )
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(router.presentEditThankYou_calledCount, 0)
        XCTAssertEqual(router.presentAlert_calledCount, 0)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasNotExistingThankYouCellTapMenuRawValue__itShouldNotEitherPresentEditThankYouOrPresentAlert() {
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "", image: nil, rawValue: 2, id: "123")
        )
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(router.presentEditThankYou_calledCount, 0)
        XCTAssertEqual(router.presentAlert_calledCount, 0)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasAvailableRawValue_andNilId__itShouldNotEitherPresentEditThankYouOrPresentAlert() {
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.edit.rawValue,
                  id: nil)
        )
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(router.presentEditThankYou_calledCount, 0)
        XCTAssertEqual(router.presentAlert_calledCount, 0)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasEditValue__itShouldDismissPresentedView_andPresentEditThankYou_withPassedThankYouId() {
        let dismissPresentedViewRecords = TestRecord(
            publisher: viewModel.outputs.dismissPresentedView.map { "" }.eraseToAnyPublisher())

        let thankYouId = "thank you id"
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.edit.rawValue,
                  id: thankYouId)
        )
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(dismissPresentedViewRecords.results, [.value("")])
        XCTAssertEqual(router.presentEditThankYou_calledCount, 1)
        XCTAssertEqual(router.presentEditThankYou_thankYouId, thankYouId)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasDeleteValue__itShouldDismissPresentedView_andPresentAlert() {
        let dismissPresentedViewRecords = TestRecord(
            publisher: viewModel.outputs.dismissPresentedView.map { "" }.eraseToAnyPublisher())

        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.delete.rawValue,
                  id: "thankYouId")
        )
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(dismissPresentedViewRecords.results, [.value("")])
        XCTAssertEqual(router.presentAlert_calledCount, 1)
        XCTAssertEqual(router.presentAlert_title, R.string.localizable.deleteThankYou())
        XCTAssertEqual(router.presentAlert_message, R.string.localizable.areYouSureYouWantToDeleteThisThankYou())
        let firstAction = router.presentAlert_actions?.first
        XCTAssertEqual(firstAction?.title, R.string.localizable.delete())
        XCTAssertEqual(firstAction?.style, .destructive)
        let secondAction = router.presentAlert_actions?[1]
        XCTAssertEqual(secondAction?.title, R.string.localizable.cancel())
        XCTAssertEqual(secondAction?.style, .cancel)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasDeleteValue_andTapsDeleteButton__itShouldCallDeleteThankYou__andEvenIfTheFirstTryFails__itShouldCallDeleteThankYouAgain() {

        // Tap delete button on menu
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.delete.rawValue,
                  id: "thankYouId")
        )
        scheduler.advance(by: .milliseconds(100))

        let deleteAction = router.presentAlert_actions?.first

        // Set delete thank you first result as failed
        thankYouRepository.deleteThankYou_result = Fail(error: NSError()).asFuture()

        // Tap delete button on confirmation halfsheet #1
        deleteAction?.action!()

        // deleteThankYou should be called once
        XCTAssertEqual(thankYouRepository.deleteThankYou_calledCount, 1)

        // Set delete thank you first result as success
        thankYouRepository.deleteThankYou_result = Just(()).setFailureType(to: Error.self).asFuture()

        // Tap delete button on confirmation halfsheet #2
        deleteAction?.action!()

        // deleteThankYou should be called twice
        XCTAssertEqual(thankYouRepository.deleteThankYou_calledCount, 2)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasDeleteValue_tapsDeleteButton_andDeleteSucceeded__itShouldSendAnalytics_withUserId_andTheThankYouDate_andShouldNotPresentAlertTwice() {

        let userId = "userId"
        userRepository.getUserProfile_result = Just(Profile(id: userId, name: "", email: "", imageUrl: nil)).setFailureType(to: Error.self).asFuture()
        let thankYouDate = Date(timeIntervalSince1970: 123456)
        thankYouRepository.loadThankYou_result = ThankYouData(id: "", value: "", encryptedValue: "", date: thankYouDate, createTime: Date())

        // Tap delete button on menu
        let thankYouId = "abcddd"
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.delete.rawValue,
                  id: thankYouId)
        )
        scheduler.advance(by: .milliseconds(100))

        let deleteAction = router.presentAlert_actions?.first

        // Set delete thank you result as success
        thankYouRepository.deleteThankYou_result = Just(()).setFailureType(to: Error.self).asFuture()

        // Tap delete button on confirmation halfsheet #1
        deleteAction?.action!()

        // Should pass correct parameters
        XCTAssertEqual(thankYouRepository.deleteThankYou_thankYouId, thankYouId)
        XCTAssertEqual(thankYouRepository.deleteThankYou_userId, userId)

        // Should send analytics
        XCTAssertEqual(analyticsManager.loggedEvent.count, 1)
        XCTAssertEqual(analyticsManager.loggedEvent.first?.eventName, AnalyticsEventConst.deleteThankYou)
        XCTAssertEqual(analyticsManager.loggedEvent.first?.userId, userId)
        XCTAssertEqual(analyticsManager.loggedEvent.first?.targetDate, thankYouDate)

        // Should not present alert twice
        XCTAssertEqual(router.presentAlert_calledCount, 1)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasDeleteValue_tapsDeleteButton_andDeleteFailed__itShouldPresentAlert_andShouldNotSendAnalytics() {

        userRepository.getUserProfile_result = Just(Profile(id: "userId", name: "", email: "", imageUrl: nil)).setFailureType(to: Error.self).asFuture()

        // Tap delete button on menu
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.delete.rawValue,
                  id: "thankYouId")
        )
        scheduler.advance(by: .milliseconds(100))

        // Should present alert
        XCTAssertEqual(router.presentAlert_calledCount, 1)
        // Reset
        router.presentAlert_calledCount = 0
        router.presentAlert_message = nil

        let deleteAction = router.presentAlert_actions?.first

        // Set delete thank you result as failure
        thankYouRepository.deleteThankYou_result = Fail(error: NSError()).asFuture()

        // Tap delete button on confirmation halfsheet #1
        deleteAction?.action!()
        scheduler.advance(by: .milliseconds(100))

        // Should present alert
        XCTAssertEqual(router.presentAlert_calledCount, 1)
        XCTAssertEqual(router.presentAlert_message, R.string.localizable.failedToDelete())

        // Should not send analytics
        XCTAssertEqual(analyticsManager.loggedEvent.count, 0)
    }

    func test_ifTheUserOpensTheScreen__itShouldOutputUpdateYearMonthLabel_withTheCurrentDate__andIfHeScrollToAnotherMonth__itShouldOutputupdateYearMonthLabel_withTheScrolledDate() {

        let updateYearMonthLabelRecords = TestRecord(
            publisher: viewModel.outputs.updateYearMonthLabel.map { $0?.replacingOccurrences(of: " ", with: "") }.eraseToAnyPublisher())

        // Opens screen
        viewModel.inputs.viewDidLoad.send()

        // Should update with current year month
        XCTAssertEqual(updateYearMonthLabelRecords.results, [
            .value(Date().toMonthYearString().replacingOccurrences(of: " ", with: "")), // Initialized value
            .value(Date().toMonthYearString().replacingOccurrences(of: " ", with: ""))
        ])

        updateYearMonthLabelRecords.clearResult()

        // Scroll to another month
        let date1 = Date(timeIntervalSince1970: 12345565)
        viewModel.inputs.calendarDidScrollToMonth.send(date1)

        // Should update with the new year month
        XCTAssertEqual(updateYearMonthLabelRecords.results, [.value(date1.toMonthYearString().replacingOccurrences(of: " ", with: ""))])
    }
}

private class MockCalendarRouter: MockRouter, CalendarRouter {
    var presentMyPage_calledCount = 0
    func presentMyPage() {
        presentMyPage_calledCount += 1
    }

    var presentEditThankYou_calledCount = 0
    var presentEditThankYou_thankYouId: String?
    func presentEditThankYou(thankYouId: String) {
        presentEditThankYou_thankYouId = thankYouId
        presentEditThankYou_calledCount += 1
    }
}
