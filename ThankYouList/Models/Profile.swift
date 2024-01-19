//
//  Profile.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/23.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import Foundation

struct Profile {
    let id: String
    let name: String
    let email: String
    let imageUrl: URL?

    init(id: String, name: String, email: String, imageUrl: URL?) {
        self.id = id
        self.name = name
        self.email = email
        self.imageUrl = imageUrl
    }
}
