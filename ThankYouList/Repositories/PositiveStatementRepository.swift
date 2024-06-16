//
//  PositiveStatementRepository.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/04/09.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import FirebaseFirestore

private let encryptedValueKey = "encryptedValue"
private let createdDateKey = "createdDate"

protocol PositiveStatementRepository {
    func subscribePositiveStatements(userId: String) -> AnyPublisher<[PositiveStatementModel], Error>
    func createPositiveStatement(positiveStatement: String, userId: String) -> Future<Void, Error>
}

struct DefaultPositiveStatementRepository: PositiveStatementRepository {

    let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    func subscribePositiveStatements(userId: String) -> AnyPublisher<[PositiveStatementModel], Error> {
        let userId16string = String(userId.prefix(16))
        return AnyPublisher<[PositiveStatementModel], Error>.create { subscriber in
            let snapshotListener = firestore
                .collection(FirestoreConst.usersCollecion)
                .document(userId)
                .collection(FirestoreConst.positiveStatementsCollection)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        subscriber.onError(error)
                    }

                    guard let documents = snapshot?.documents else { return }
                    let positiveStatements = documents
                        .compactMap { document -> PositiveStatementModel? in
                            let data = document.data()
                            guard let encryptedValue = data[encryptedValueKey] as? String,
                                  let createdDate = data[createdDateKey] as? Timestamp else { return nil }
                            let decryptedValue = Crypto().decryptString(
                                encryptText: encryptedValue,
                                key: userId16string)
                            return PositiveStatementModel(
                                value: decryptedValue,
                                createdDate: createdDate.dateValue())
                        }
                    subscriber.onNext(positiveStatements)
                }
            return AnyCancellable {
                snapshotListener.remove()
            }
        }
    }

    func createPositiveStatement(positiveStatement: String, userId: String) -> Future<Void, Error> {
        let userId16string = String(userId.prefix(16))
        let encryptedValue = Crypto().encryptString(
            plainText: positiveStatement,
            key: userId16string)
        let positiveStatementCreate = PositiveStatementCreateModel(
            encryptedValue: encryptedValue,
            createdDate: Date())
        return Future<Void, Error> { promise in
            firestore
                .collection(FirestoreConst.usersCollecion)
                .document(userId)
                .collection(FirestoreConst.positiveStatementsCollection)
                .addDocument(data: positiveStatementCreate.dictionary) { error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    promise(.success(()))
                }
        }
    }
}
