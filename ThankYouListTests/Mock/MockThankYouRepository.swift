//
//  MockThankYouRepository.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2023/10/08.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Combine
@testable import ThankYouList

class MockThankYouRepository: ThankYouRepository {

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
