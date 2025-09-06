//
//  InMemoryDataStore.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/09/19.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Foundation

protocol InMemoryDataStore {
    var thankYouList: [ThankYouData] { get set }
    var selectedDate: Date { get set }
}

class DefaultInMemoryDataStore: InMemoryDataStore {

    private init() {}
    static var shared = DefaultInMemoryDataStore()

    var _thankYouList: [ThankYouData] = []
    var thankYouList: [ThankYouData] {
        get {
            _thankYouList
        }
        set {
            _thankYouList = newValue
        }
    }

    var _selectedDate: Date = Date()
    var selectedDate: Date {
        get {
            _selectedDate
        }
        set {
            _selectedDate = newValue
        }
    }
}
