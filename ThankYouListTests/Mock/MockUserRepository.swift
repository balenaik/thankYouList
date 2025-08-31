//
//  MockUserRepository.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2023/04/01.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Combine
@testable import ThankYouList

class MockUserRepository: UserRepository {

    var isLoggedIn_result = true
    func isLoggedIn() -> Bool {
        isLoggedIn_result
    }

    var getUserProfile_result = Just(Profile(id: "", name: "", email: "", imageUrl: nil))
        .setFailureType(to: Error.self).asFuture()
    var getUserProfile_calledCount = 0
    func getUserProfile() -> Future<Profile, Error> {
        getUserProfile_calledCount += 1
        return getUserProfile_result
    }

    var reAuthenticateToProviderIfNeeded_result = Just(()).setFailureType(to: Error.self).asFuture()
    func reAuthenticateToProviderIfNeeded() -> Future<Void, Error> {
        reAuthenticateToProviderIfNeeded_result
    }

    var deleteAccount_result = Just(()).setFailureType(to: Error.self).asFuture()
    func deleteAccount() -> Future<Void, Error> {
        deleteAccount_result
    }

    var observeAuthenticationChanges_result = Just(nil as String?).setFailureType(to: Error.self).eraseToAnyPublisher()
    func observeAuthenticationChanges() -> AnyPublisher<String?, Error> {
        observeAuthenticationChanges_result
    }
}
