//
//  UserRepository.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/04.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import FirebaseAuth

protocol UserRepository {
    func isLoggedIn() -> Bool
    func getUserProfile() -> Profile?
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
}
