//
//  ThankYouRepository.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/09/24.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Combine
import FirebaseFirestore

protocol ThankYouRepository {
    func loadThankYou(thankYouId: String) -> ThankYouData?
    func deleteThankYou(thankYouId: String, userId: String) -> Future<Void, Error>
}

struct DefaultThankYouRepository: ThankYouRepository {

    let firestore: Firestore
    let inMemoryDataStore: InMemoryDataStore

    init(firestore: Firestore = Firestore.firestore(),
         inMemoryDataStore: InMemoryDataStore = DefaultInMemoryDataStore.shared) {
        self.firestore = firestore
        self.inMemoryDataStore = inMemoryDataStore
    }

    func loadThankYou(thankYouId: String) -> ThankYouData? {
        inMemoryDataStore.thankYouList.first(where: { $0.id == thankYouId })
    }

    func deleteThankYou(thankYouId: String, userId: String) -> Future<Void, Error> {
        Future<Void, Error> { promise in
            firestore
                .collection(FirestoreConst.usersCollecion)
                .document(userId)
                .collection(FirestoreConst.thankYouListCollection)
                .document(thankYouId)
                .delete(completion: { error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    promise(.success(()))
                })
        }
    }
}
