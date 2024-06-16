//
//  PositiveStatementListViewModelTests.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2024/06/16.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import XCTest
import Combine
@testable import ThankYouList

final class PositiveStatementListViewModelTests: XCTestCase {

    private var viewModel: PositiveStatementListViewModel!
    private var userRepository: MockUserRepository!
    private var positiveStatementRepository: MockPositiveStatementRepository!
    private var router: MockPositiveStatementListRouter!

    override func setUp() {
        userRepository = MockUserRepository()
        positiveStatementRepository = MockPositiveStatementRepository()
        router = MockPositiveStatementListRouter()

        viewModel = PositiveStatementListViewModel(
            userRepository: userRepository,
            positiveStatementRepository: positiveStatementRepository,
            router: router)
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

        let positiveStatementsRecords = TestRecord(publisher: viewModel.outputs.positiveStatements.eraseToAnyPublisher())
        positiveStatementsRecords.clearResult()

        // Open the screen
        viewModel.inputs.onAppear.send()

        // Send first event
        let firstPositiveStatements = [
            PositiveStatementModel(value: "value1", createdDate: Date()),
            PositiveStatementModel(value: "value2", createdDate: Date()),
            PositiveStatementModel(value: "value3", createdDate: Date())
        ]
        positiveStatementsRelay.send(firstPositiveStatements)

        // It should output positiveStatements
        XCTAssertEqual(positiveStatementsRecords.results, [
            .value(firstPositiveStatements)
        ])
        positiveStatementsRecords.clearResult()

        // Send second event
        let secondPositiveStatements = [
            PositiveStatementModel(value: "value4", createdDate: Date()),
            PositiveStatementModel(value: "value5", createdDate: Date()),
            PositiveStatementModel(value: "value6", createdDate: Date())
        ]
        positiveStatementsRelay.send(secondPositiveStatements)

        // It should output positiveStatements
        XCTAssertEqual(positiveStatementsRecords.results, [
            .value(secondPositiveStatements)
        ])
    }
}

private class MockPositiveStatementListRouter: MockRouter, PositiveStatementListRouter {
    var presentAddPositiveStatement_calledCount = 0
    func presentAddPositiveStatement() {
        presentAddPositiveStatement_calledCount += 1
    }
}
