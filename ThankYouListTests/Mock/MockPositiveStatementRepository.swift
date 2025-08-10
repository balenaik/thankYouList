//
//  MockPositiveStatementRepository.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2024/04/25.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import Foundation

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

    var getPositiveStatement_calledCount = 0
    var getPositiveStatement_positiveStatementId: String?
    var getPositiveStatement_userId: String?
    var getPositiveStatement_result = Just(PositiveStatementModel(id: "", value: "", createdDate: Date())).setFailureType(to: Error.self).asFuture()
    func getPositiveStatement(positiveStatementId: String, userId: String) -> Future<ThankYouList.PositiveStatementModel, any Error> {
        getPositiveStatement_calledCount += 1
        getPositiveStatement_positiveStatementId = positiveStatementId
        getPositiveStatement_userId = userId
        return getPositiveStatement_result
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

    var updatePositiveStatement_calledCount = 0
    var updatePositiveStatement_positiveStatementId: String?
    var updatePositiveStatement_positiveStatement: String?
    var updatePositiveStatement_userId: String?
    var updatePositiveStatement_result = Just(()).setFailureType(to: Error.self).asFuture()
    func updatePositiveStatement(positiveStatementId: String, positiveStatement: String, userId: String) -> Future<Void, any Error> {
        updatePositiveStatement_calledCount += 1
        updatePositiveStatement_positiveStatementId = positiveStatementId
        updatePositiveStatement_positiveStatement = positiveStatement
        updatePositiveStatement_userId = userId
        return updatePositiveStatement_result
    }

    var deletePositiveStatement_calledCount = 0
    var deletePositiveStatement_positiveStatementId: String?
    var deletePositiveStatement_userId: String?
    var deletePositiveStatement_result = Just(()).setFailureType(to: Error.self).asFuture()
    func deletePositiveStatement(positiveStatementId: String, userId: String) -> Future<Void, any Error> {
        deletePositiveStatement_positiveStatementId = positiveStatementId
        deletePositiveStatement_userId = userId
        deletePositiveStatement_calledCount += 1
        return deletePositiveStatement_result
    }
}
