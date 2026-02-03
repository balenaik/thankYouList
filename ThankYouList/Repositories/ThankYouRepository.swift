//
//  ThankYouRepository.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/09/24.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Combine
import FirebaseFirestore
import SharedResources

private let encryptedValueKey = "encryptedValue"
private let dateKey = "date"
private let createdDateKey = "createdDate"

enum ThankYouRepositoryError: Error {
    case selfNotFound
    case snapshotNotFound
}

enum ThankYouListChange {
    case added(ThankYouData)
    case updated(from: ThankYouData, to: ThankYouData)
    case removed(ThankYouData)
    case error(Error)
}

protocol ThankYouRepository {
    func subscribeThankYouList(userId: String) -> AnyPublisher<ThankYouListChange, Never>
    func loadThankYou(thankYouId: String) -> ThankYouData?
    func deleteThankYou(thankYouId: String, userId: String) -> Future<Void, Error>
}

class DefaultThankYouRepository: ThankYouRepository {

    let firestore: Firestore
    var inMemoryDataStore: InMemoryDataStore

    init(firestore: Firestore = Firestore.firestore(),
         inMemoryDataStore: InMemoryDataStore = DefaultInMemoryDataStore.shared) {
        self.firestore = firestore
        self.inMemoryDataStore = inMemoryDataStore
    }

    func subscribeThankYouList(userId: String) -> AnyPublisher<ThankYouListChange, Never> {
        return AnyPublisher<ThankYouListChange, Never>.create { [weak self] subscriber in
            guard let self else {
                subscriber.onNext(.error(ThankYouRepositoryError.selfNotFound))
                return AnyCancellable {}
            }
            let snapshotListener = self.firestore
                .collection(FirestoreConst.usersCollecion)
                .document(userId)
                .collection(FirestoreConst.thankYouListCollection)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        subscriber.onNext(.error(error))
                        return
                    }
                    guard let snapshot else {
                        subscriber.onNext(.error(ThankYouRepositoryError.snapshotNotFound))
                        return
                    }
                    let currentInMemoryThankYouList = self.inMemoryDataStore.thankYouList
                    snapshot.documentChanges.forEach { change in
                        switch change.type {
                        case .added:
                            let thankYouData = ThankYouData(
                                id: change.document.documentID,
                                userId: userId,
                                dictionary: change.document.data()
                            )
                            guard let thankYouData,
                                  !currentInMemoryThankYouList.map(\.id).contains(thankYouData.id) else {
                                return
                            }
                            self.inMemoryDataStore.thankYouList.append(thankYouData)
                            subscriber.onNext(.added(thankYouData))
                        default: break
                        }
                    }
                }
            return AnyCancellable {
                snapshotListener.remove()
            }
        }
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

private extension ThankYouData {
    init?(id: String, userId: String, dictionary: [String : Any]) {
        guard let encryptedValue = dictionary[encryptedValueKey] as? String,
              let dateString = dictionary[dateKey] as? String,
              let date = dateString.toDate(format: R.string.localizable.date_format_thankyou_date()),
              let createTime = dictionary[createdDateKey] as? Timestamp else {
            return nil
        }
        let userId16string = String(userId.prefix(16))
        let decryptedValue = CryptoManager().decryptString(encryptText: encryptedValue, key: userId16string)
        self.init(
            id: id,
            value: decryptedValue,
            encryptedValue: encryptedValue,
            date: date,
            createTime: createTime.dateValue()
        )
    }
}
