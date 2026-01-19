//
//  UserDefaultsDataStore.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2026/01/10.
//  Copyright © 2026 Aika Yamada. All rights reserved.
//

import Foundation

protocol UserDefaultsDataStore {
    var hasSeenPositiveStatementOnboarding: Bool { get set }
}

final class DefaultUserDefaultsDataStore: UserDefaultsDataStore {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var hasSeenPositiveStatementOnboarding: Bool {
        get { get(UserDefaultsKeys.hasSeenPositiveStatementOnboarding) }
        set { set(newValue, for: UserDefaultsKeys.hasSeenPositiveStatementOnboarding) }
    }
}

private extension DefaultUserDefaultsDataStore {
    func get<T>(_ key: UserDefaultsKey<T>) -> T {
        userDefaults.object(forKey: key.key) as? T ?? key.defaultValue
    }

    func set<T>(_ value: T, for key: UserDefaultsKey<T>) {
        userDefaults.set(value, forKey: key.key)
    }
}

private struct UserDefaultsKey<Value> {
    let key: String
    let defaultValue: Value
}

private enum UserDefaultsKeys {
    static let hasSeenPositiveStatementOnboarding = UserDefaultsKey<Bool>(
        key: "hasSeenPositiveStatementOnboarding",
        defaultValue: false
    )
}
