//
//  MockInMemoryDataStore.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2023/10/08.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Foundation
@testable import ThankYouList

class MockInMemoryDataStore: InMemoryDataStore {
    var thankYouList = [ThankYouList.ThankYouData]()

    var selectedDate = Date()
}
