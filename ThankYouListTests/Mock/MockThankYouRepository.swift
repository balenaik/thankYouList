//
//  MockThankYouRepository.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2023/10/08.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Combine
import Foundation
@testable import ThankYouList

class MockThankYouRepository: ThankYouRepository {
    var subscribeThankYouList_result: AnyPublisher<ThankYouListChange, Never> = Just(.added(ThankYouData(id: "", value: "", encryptedValue: "", date: Date(), createTime: Date()))).eraseToAnyPublisher()
    var subscribeThankYouList_userId: String?
    var subscribeThankYouList_calledCount = 0
    func subscribeThankYouList(userId: String) -> AnyPublisher<ThankYouListChange, Never> {
        subscribeThankYouList_userId = userId
        subscribeThankYouList_calledCount += 1
        return subscribeThankYouList_result
    }

    var loadThankYou_result: ThankYouData?
    var loadThankYou_thankYouId: String?
    func loadThankYou(thankYouId: String) -> ThankYouData? {
        loadThankYou_thankYouId = thankYouId
        return loadThankYou_result
    }

    var deleteThankYou_result = Just(()).setFailureType(to: Error.self).asFuture()
    var deleteThankYou_thankYouId: String?
    var deleteThankYou_userId: String?
    var deleteThankYou_calledCount = 0
    func deleteThankYou(thankYouId: String, userId: String) -> Future<Void, Error> {
        deleteThankYou_thankYouId = thankYouId
        deleteThankYou_userId = userId
        deleteThankYou_calledCount += 1
        return deleteThankYou_result
    }
}
