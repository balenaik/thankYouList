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
}

struct DefaultUserRepository: UserRepository {
    func isLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}
