//
//  MockPositiveStatementRepository.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2024/04/25.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
@testable import ThankYouList

class MockPositiveStatementRepository: PositiveStatementRepository {
    var subscribePositiveStatements_calledCount = 0
    var subscribePositiveStatements_userId: String?
    var subscribePositiveStatements_result = Just([PositiveStatementModel]()).setFailureType(to: Error.self).eraseToAnyPublisher()
    func subscribePositiveStatements(userId: String) -> AnyPublisher<[PositiveStatementModel], Error> {
        subscribePositiveStatements_calledCount += 1
        subscribePositiveStatements_userId = userId
        return subscribePositiveStatements_result
    }

    var createPositiveStatement_calledCount = 0
    var createPositiveStatement_positiveStatement: String?
    var createPositiveStatement_userId: String?
    var createPositiveStatement_result = Just(()).setFailureType(to: Error.self).asFuture()
    func createPositiveStatement(positiveStatement: String, userId: String) -> Future<Void, Error> {
        createPositiveStatement_positiveStatement = positiveStatement
        createPositiveStatement_userId = userId
        createPositiveStatement_calledCount += 1
        return createPositiveStatement_result
    }
}
