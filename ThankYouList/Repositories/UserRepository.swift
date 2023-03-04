//
//  UserRepository.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/04.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import FirebaseAuth
import Combine

enum UserRepositoryError: Error {
    case currentUserNotExist
}

protocol UserRepository {
    func isLoggedIn() -> Bool
    func getUserProfile() -> Profile?
    func deleteAccount() -> Future<Void, Error>
}

struct DefaultUserRepository: UserRepository {
    func isLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }

    func getUserProfile() -> Profile? {
        guard let user = Auth.auth().currentUser else { return nil }
        var email = user.email
        if email == nil {
            // For accounts whose email is not correctly registered to Firebase
            // e.g. The same email has been already registered in another account by other method
            email = user.providerData.first?.email
        }
        let profile = Profile(name: user.displayName ?? "",
                              email: email ?? "",
                              imageUrl: user.providerData.first?.photoURL) // To get photoURL with Google Authentication since user.photoURL has 404 data
        return profile
    }

    func deleteAccount() -> Future<Void, Error> {
        return Future<Void, Error> { promise in
            guard let user = Auth.auth().currentUser else {
                promise(.failure(UserRepositoryError.currentUserNotExist))
                return
            }
            user.delete() { error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                promise(.success(()))
            }
        }
    }
}
