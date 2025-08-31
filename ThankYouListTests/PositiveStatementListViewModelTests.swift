//
//  PositiveStatementListViewModelTests.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2024/06/16.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import XCTest
import Combine
import CombineSchedulers
@testable import ThankYouList

final class PositiveStatementListViewModelTests: XCTestCase {

    private var viewModel: PositiveStatementListViewModel!
    private var userRepository: MockUserRepository!
    private var positiveStatementRepository: MockPositiveStatementRepository!
    private var router: MockPositiveStatementListRouter!
    private var scheduler: TestSchedulerOf<DispatchQueue>!
    private var analyticsManager: MockAnalyticsManager!

    override func setUp() {
        userRepository = MockUserRepository()
        positiveStatementRepository = MockPositiveStatementRepository()
        router = MockPositiveStatementListRouter()
        scheduler = DispatchQueue.test
        analyticsManager = MockAnalyticsManager()

        viewModel = PositiveStatementListViewModel(
            userRepository: userRepository,
            positiveStatementRepository: positiveStatementRepository,
            router: router,
            scheduler: scheduler.eraseToAnyScheduler(),
            analyticsManager: analyticsManager
        )
    }

    func test_ifAUserOpensTheScreen_multipleTimes__itShouldCallGetUserProfile_onlyOnce() {
        // Open the screen once
        viewModel.inputs.onAppear.send()
        // It should call getUserProfile once
        XCTAssertEqual(userRepository.getUserProfile_calledCount, 1)
        userRepository.getUserProfile_calledCount = 0

        // Open the screen more
        viewModel.inputs.onAppear.send()
        viewModel.inputs.onAppear.send()
        // It should not call getUserProfile anymore
        XCTAssertEqual(userRepository.getUserProfile_calledCount, 0)
    }

    func test_ifAUserOpensTheScreen__itShouldSubscribePostitiveStatements_andPassUserId() {
        // Set a mock result to return userId on getUserProfile
        let userId = "userId"
        userRepository.getUserProfile_result = Just(Profile(id: userId, name: "", email: "", imageUrl: nil)).setFailureType(to: Error.self).asFuture()

        // Open the screen
        viewModel.inputs.onAppear.send()

        // It should call subscribePostitiveStatements
        XCTAssertEqual(positiveStatementRepository.subscribePositiveStatements_calledCount, 1)
        // It should pass userId
        XCTAssertEqual(positiveStatementRepository.subscribePositiveStatements_userId, userId)
    }

    func test_ifAUserOpensTheScreen_andSubscribePostitiveStatementsSucceeds__itShouldUpdatePositiveStatements() {
        let positiveStatementsRelay = PassthroughSubject<[PositiveStatementModel], Error>()
        positiveStatementRepository.subscribePositiveStatements_result = positiveStatementsRelay.eraseToAnyPublisher()

        let positiveStatementsRecords = TestRecord(publisher: viewModel.outputs.$positiveStatements.eraseToAnyPublisher())
        positiveStatementsRecords.clearResult()

        // Open the screen
        viewModel.inputs.onAppear.send()

        // Send first event
        let firstPositiveStatements = [
            PositiveStatementModel(id: "id1", value: "value1", createdDate: Date()),
            PositiveStatementModel(id: "id2", value: "value2", createdDate: Date()),
            PositiveStatementModel(id: "id3", value: "value3", createdDate: Date())
        ]
        positiveStatementsRelay.send(firstPositiveStatements)

        // It should output positiveStatements
        XCTAssertEqual(positiveStatementsRecords.results, [
            .value(firstPositiveStatements)
        ])
        positiveStatementsRecords.clearResult()

        // Send second event
        let secondPositiveStatements = [
            PositiveStatementModel(id: "id4", value: "value4", createdDate: Date()),
            PositiveStatementModel(id: "id5", value: "value5", createdDate: Date()),
            PositiveStatementModel(id: "id6", value: "value6", createdDate: Date())
        ]
        positiveStatementsRelay.send(secondPositiveStatements)

        // It should output positiveStatements
        XCTAssertEqual(positiveStatementsRecords.results, [
            .value(secondPositiveStatements)
        ])
    }

    func test_ifAUserOpensTheScreen_andSubscribePositiveStatementsFails__itShouldPresentErrorAlert() {
        // Set an error result on subscribePositiveStatements
        positiveStatementRepository.subscribePositiveStatements_result = Fail(error: NSError()).eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.onAppear.send()

        // It should present an error alert
        XCTAssertEqual(router.presentAlert_calledCount, 1)
        XCTAssertEqual(router.presentAlert_title, R.string.localizable.something_went_wrong_title())
        XCTAssertEqual(router.presentAlert_message, R.string.localizable.positive_statement_list_error_message())
    }

    func test_ifAUserOpensTheScreen_subscribePositiveStatementsFails_andTapsOKOnTheAlert__itShouldPopToPreviousScreen() {
        // Set an error result on subscribePositiveStatements
        positiveStatementRepository.subscribePositiveStatements_result = Fail(error: NSError()).eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.onAppear.send()

        // Taps OK on the error alert
        router.presentAlert_actions?.first?.action?()

        // It should pop to previous screen
        XCTAssertEqual(router.popToPreviousScreen_calledCount, 1)
    }

    func test_ifPositiveStatementCountLessThanOrEqualTo9__itShouldEnableAddButton() {
        let positiveStatementsRelay = PassthroughSubject<[PositiveStatementModel], Error>()
        positiveStatementRepository.subscribePositiveStatements_result = positiveStatementsRelay.eraseToAnyPublisher()

        let isAddButtonDisabledRecords = TestRecord(publisher: viewModel.outputs.$isAddButtonDisabled.eraseToAnyPublisher())

        // add button should be initially disabled
        XCTAssertEqual(isAddButtonDisabledRecords.results, [
            .value(true)
        ])
        isAddButtonDisabledRecords.clearResult()

        // Open the screen
        viewModel.inputs.onAppear.send()

        // 8 positive statements
        positiveStatementsRelay.send(Array(repeating: PositiveStatementModel(id: "", value: "", createdDate: Date()), count: 8))
        // It should enable add button
        XCTAssertEqual(isAddButtonDisabledRecords.results, [
            .value(false)
        ])
        isAddButtonDisabledRecords.clearResult()

        // 3 positive statements
        positiveStatementsRelay.send(Array(repeating: PositiveStatementModel(id: "", value: "", createdDate: Date()), count: 3))
        // It should enable add button
        XCTAssertEqual(isAddButtonDisabledRecords.results, [
            .value(false)
        ])
    }

    func test_ifPositiveStatementCountMoreThan9__itShouldEnableAddButton() {
        let positiveStatementsRelay = PassthroughSubject<[PositiveStatementModel], Error>()
        positiveStatementRepository.subscribePositiveStatements_result = positiveStatementsRelay.eraseToAnyPublisher()

        let isAddButtonDisabledRecords = TestRecord(publisher: viewModel.outputs.$isAddButtonDisabled.eraseToAnyPublisher())
        isAddButtonDisabledRecords.clearResult()

        // Open the screen
        viewModel.inputs.onAppear.send()

        // 10 positive statements
        positiveStatementsRelay.send(Array(repeating: PositiveStatementModel(id: "", value: "", createdDate: Date()), count: 10))
        // It should disable add button
        XCTAssertEqual(isAddButtonDisabledRecords.results, [
            .value(true)
        ])
        isAddButtonDisabledRecords.clearResult()

        // 15 positive statements
        positiveStatementsRelay.send(Array(repeating: PositiveStatementModel(id: "", value: "", createdDate: Date()), count: 15))
        // It should disable add button
        XCTAssertEqual(isAddButtonDisabledRecords.results, [
            .value(true)
        ])
    }

    func test_ifAUserTapsAddButton__itShouldPresentAddPositiveStatement() {
        // Taps add button
        viewModel.inputs.addButtonDidTap.send()

        // It should present AddPositiveStatement
        XCTAssertEqual(router.presentAddPositiveStatement_calledCount, 1)
    }

    func test_ifAUserTapsWidgetHintButton__itShouldPresentHomeWidgetInstruction() {
        // Taps widget hint button
        viewModel.inputs.widgetHintButtonDidTap.send()

        // It should present home widget instruction
        XCTAssertEqual(router.presentHomeWidgetInstruction_calledCount, 1)
    }

    func test_ifAUserTapsPositiveStatementMenuButton__itShouldOutputBottomMenuList() {
        let bottomMenuListRecords = TestRecord(publisher: viewModel.outputs.$bottomMenuList.eraseToAnyPublisher())
        bottomMenuListRecords.clearResult()

        // User taps positive statment menu button
        viewModel.inputs.positiveStatementMenuButtonDidTap.send("")

        // It should output all bottom menu list
        XCTAssertEqual(bottomMenuListRecords.results, [.value(PositiveStatementTapMenu.allCases)])
    }

    func test_ifAUserTapsPositiveStatementMenuButton__itShouldShowBottomMenu() {
        let showBottomMenuRecords = TestRecord(publisher: viewModel.outputs.$showBottomMenu.eraseToAnyPublisher())
        showBottomMenuRecords.clearResult()

        // User taps positive statment menu button
        viewModel.inputs.positiveStatementMenuButtonDidTap.send("")

        // It shoud show bottom menu
        XCTAssertEqual(showBottomMenuRecords.results, [.value(true)])
    }

    func test_ifAUserTapsBottomMenu__itShouldHideBottomMenu() {
        let showBottomMenuRecords = TestRecord(publisher: viewModel.outputs.$showBottomMenu.eraseToAnyPublisher())
        showBottomMenuRecords.clearResult()

        // User taps bottom menu
        viewModel.inputs.bottomMenuDidTap.send(.delete)

        // It shoud hide bottom menu
        XCTAssertEqual(showBottomMenuRecords.results, [.value(false)])
    }

    func test_ifAUserTapsBottomMenu_asDelete__itShouldShowAlert() {
        let showAlertTitleRecords = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.title).eraseToAnyPublisher())
        let showAlertMessageRecords = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.message).eraseToAnyPublisher())
        let showAlertPrimaryActionTitleRecords = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.primaryAction?.title).eraseToAnyPublisher())
        let showAlertPrimaryActionStyleRecords = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.primaryAction?.style).eraseToAnyPublisher())
        let showAlertSecondaryActionTitleRecords = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.secondaryAction?.title).eraseToAnyPublisher())
        let showAlertSecondaryActionStyleRecords = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.secondaryAction?.style).eraseToAnyPublisher())
        showAlertTitleRecords.clearResult()
        showAlertMessageRecords.clearResult()
        showAlertPrimaryActionTitleRecords.clearResult()
        showAlertPrimaryActionStyleRecords.clearResult()
        showAlertSecondaryActionTitleRecords.clearResult()
        showAlertSecondaryActionStyleRecords.clearResult()

        // User taps positive statment menu button
        viewModel.inputs.positiveStatementMenuButtonDidTap.send("")
        // User taps delete bottom menu
        viewModel.inputs.bottomMenuDidTap.send(.delete)

        // Wait for 10ms
        scheduler.advance(by: .milliseconds(10))

        // It should show alert
        XCTAssertEqual(showAlertTitleRecords.results, [.value(R.string.localizable.positive_statement_list_confirm_delete_title())])
        XCTAssertEqual(showAlertMessageRecords.results, [.value(R.string.localizable.positive_statement_list_confirm_delete_message())])
        XCTAssertEqual(showAlertPrimaryActionTitleRecords.results, [.value(R.string.localizable.delete())])
        XCTAssertEqual(showAlertSecondaryActionTitleRecords.results, [.value(R.string.localizable.cancel())])
        XCTAssertEqual(showAlertPrimaryActionStyleRecords.results, [.value(.destructive)])
        XCTAssertEqual(showAlertSecondaryActionStyleRecords.results, [.value(.cancel)])
    }

    func test_ifAUserTapsBottomMenu_asDelete_andTapsDeleteButton__itShouldCallDeletePositiveStatement() {
        let userId = "userId"
        userRepository.getUserProfile_result = Just(Profile(id: userId, name: "", email: "", imageUrl: nil)).setFailureType(to: Error.self).asFuture()

        // onAppear (to get userProfile)
        viewModel.inputs.onAppear.send()
        // User taps positive statment menu button
        let positiveStatementId = "positiveStatementId"
        viewModel.inputs.positiveStatementMenuButtonDidTap.send(positiveStatementId)
        // User taps delete bottom menu
        viewModel.inputs.bottomMenuDidTap.send(.delete)
        // Wait for 10ms
        scheduler.advance(by: .milliseconds(10))
        // User taps delete button
        viewModel.outputs.showAlert?.primaryAction?.action?()

        // It should call getUserProfile only once
        XCTAssertEqual(userRepository.getUserProfile_calledCount, 1)
        // It should call deletePositiveStatement
        XCTAssertEqual(positiveStatementRepository.deletePositiveStatement_calledCount, 1)
        // It should pass userId and positiveStatementId
        XCTAssertEqual(positiveStatementRepository.deletePositiveStatement_userId, userId)
        XCTAssertEqual(positiveStatementRepository.deletePositiveStatement_positiveStatementId, positiveStatementId)
    }

    func test_ifAUserTapsTapsDeleteButtonOnTheAlert_andDeleteFails__itShouldShowAnAlert() {
        let showAlertTitleRecords = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.title).eraseToAnyPublisher())

        // Delete API fails
        positiveStatementRepository.deletePositiveStatement_result = Fail(error: NSError()).asFuture()
        // onAppear (to get userProfile)
        userRepository.getUserProfile_result = Just(Profile(id: "", name: "", email: "", imageUrl: nil)).setFailureType(to: Error.self).asFuture()
        viewModel.inputs.onAppear.send()
        // User taps positive statment menu button
        viewModel.inputs.positiveStatementMenuButtonDidTap.send("")
        // User taps delete bottom menu
        viewModel.inputs.bottomMenuDidTap.send(.delete)
        // Wait for 10ms
        scheduler.advance(by: .milliseconds(10))
        showAlertTitleRecords.clearResult()
        // User taps delete button
        viewModel.outputs.showAlert?.primaryAction?.action?()
        scheduler.run()

        // It should show an alert
        XCTAssertEqual(showAlertTitleRecords.results, [.value(R.string.localizable.failedToDelete())])
    }

    func test_ifAUserTapsTapsDeleteButtonOnTheAlert_andGetProfileFails__itShouldNotShowAnAlert() {
        let showAlertTitleRecords = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.title).eraseToAnyPublisher())

        // Get Profile API fails
        userRepository.getUserProfile_result = Fail(error: NSError()).asFuture()
        // Delete API succeeds
        positiveStatementRepository.deletePositiveStatement_result = Just(()).setFailureType(to: Error.self).asFuture()
        // onAppear (to get userProfile)
        viewModel.inputs.onAppear.send()
        // User taps positive statment menu button
        viewModel.inputs.positiveStatementMenuButtonDidTap.send("")
        // User taps delete bottom menu
        viewModel.inputs.bottomMenuDidTap.send(.delete)
        // Wait for 10ms
        scheduler.advance(by: .milliseconds(10))
        showAlertTitleRecords.clearResult()
        // User taps delete button
        viewModel.outputs.showAlert?.primaryAction?.action?()
        scheduler.run()

        // It should not show an alert
        XCTAssertTrue(showAlertTitleRecords.results.isEmpty)
    }

    func test_ifAUserTapsTapsEditButtonOnTheAlert__itShouldPresentEditPositiveStatement() {
        let positiveStatementId = "positiveStatementId"
        // User taps positive statment menu button
        viewModel.inputs.positiveStatementMenuButtonDidTap.send(positiveStatementId)
        // User taps edit bottom menu
        viewModel.inputs.bottomMenuDidTap.send(.edit)
        // Wait for 10ms
        scheduler.advance(by: .milliseconds(10))

        // It should present EditPositiveStatement
        XCTAssertEqual(router.presentEditPositiveStatement_calledCount, 1)
        XCTAssertEqual(router.presentEditPositiveStatement_positiveStatementId, positiveStatementId)
    }

    func test_onAppear__itShouldSendLog() {
        viewModel.inputs.onAppear.send()
        XCTAssertEqual(analyticsManager.loggedEvent.count, 1)
        XCTAssertEqual(analyticsManager.loggedEvent.first?.eventName, AnalyticsEventConst.openPositiveStatementList)
    }
}

private class MockPositiveStatementListRouter: MockRouter, PositiveStatementListRouter {
    var popToPreviousScreen_calledCount = 0
    func popToPreviousScreen() {
        popToPreviousScreen_calledCount += 1
    }
    
    var presentAddPositiveStatement_calledCount = 0
    func presentAddPositiveStatement() {
        presentAddPositiveStatement_calledCount += 1
    }

    var presentEditPositiveStatement_calledCount = 0
    var presentEditPositiveStatement_positiveStatementId: String?
    func presentEditPositiveStatement(positiveStatementId: String) {
        presentEditPositiveStatement_calledCount += 1
        presentEditPositiveStatement_positiveStatementId = positiveStatementId
    }

    var presentHomeWidgetInstruction_calledCount = 0
    func presentHomeWidgetInstruction() {
        presentHomeWidgetInstruction_calledCount += 1
    }
}
