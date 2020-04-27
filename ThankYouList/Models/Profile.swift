//
//  Profile.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/23.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import Foundation

class Profile {
    let name: String
    let emailAddress: String
    let imageUrl: URL?

    init(name: String, emailAddress: String, imageUrl: URL?) {
        self.name = name
        self.emailAddress = emailAddress
        self.imageUrl = imageUrl
    }
}
