//
//  PositiveStatementRepository.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/04/09.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import FirebaseFirestore
import SharedResources

private let encryptedValueKey = "encryptedValue"
private let createdDateKey = "createdDate"

enum PositiveStatementRepositoryError: Error {
    case documentNotFound
}

protocol PositiveStatementRepository {
    func subscribePositiveStatements(userId: String) -> AnyPublisher<[PositiveStatementModel], Error>
    func getPositiveStatement(positiveStatementId: String, userId: String) -> Future<PositiveStatementModel, Error>
    func createPositiveStatement(positiveStatement: String, userId: String) -> Future<Void, Error>
    func updatePositiveStatement(positiveStatementId: String, positiveStatement: String, userId: String) -> Future<Void, Error>
    func deletePositiveStatement(positiveStatementId: String, userId: String) -> Future<Void, Error>
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
                            let decryptedValue = CryptoManager().decryptString(
                                encryptText: encryptedValue,
                                key: userId16string)
                            return PositiveStatementModel(
                                id: document.documentID,
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

    func getPositiveStatement(positiveStatementId: String, userId: String) -> Future<PositiveStatementModel, Error> {
        let userId16string = String(userId.prefix(16))
        return Future<PositiveStatementModel, Error> { promise in
            firestore
                .collection(FirestoreConst.usersCollecion)
                .document(userId)
                .collection(FirestoreConst.positiveStatementsCollection)
                .document(positiveStatementId)
                .getDocument { document, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    guard let document,
                          let encryptedValue = document.data()?[encryptedValueKey] as? String,
                          let createdDate = document.data()?[createdDateKey] as? Timestamp
                    else {
                        promise(.failure(PositiveStatementRepositoryError.documentNotFound))
                        return
                    }
                    let decryptedValue = CryptoManager().decryptString(
                        encryptText: encryptedValue,
                        key: userId16string
                    )
                    let positiveStatement = PositiveStatementModel(
                        id: document.documentID,
                        value: decryptedValue,
                        createdDate: createdDate.dateValue()
                    )
                    promise(.success(positiveStatement))
                }
        }
    }

    func createPositiveStatement(positiveStatement: String, userId: String) -> Future<Void, Error> {
        let userId16string = String(userId.prefix(16))
        let encryptedValue = CryptoManager().encryptString(
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

    func updatePositiveStatement(positiveStatementId: String, positiveStatement: String, userId: String) -> Future<Void, any Error> {
        let userId16string = String(userId.prefix(16))
        let encryptedValue = CryptoManager().encryptString(
            plainText: positiveStatement,
            key: userId16string)
        let positiveStatementUpdate = PositiveStatementUpdateModel(
            encryptedValue: encryptedValue,
            createdDate: Date())
        return Future<Void, Error> { promise in
            firestore
                .collection(FirestoreConst.usersCollecion)
                .document(userId)
                .collection(FirestoreConst.positiveStatementsCollection)
                .document(positiveStatementId)
                .updateData(positiveStatementUpdate.dictionary) { error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    promise(.success(()))
                }
        }
    }

    func deletePositiveStatement(positiveStatementId: String, userId: String) -> Future<Void, Error> {
        return Future<Void, Error> { promise in
            firestore
                .collection(FirestoreConst.usersCollecion)
                .document(userId)
                .collection(FirestoreConst.positiveStatementsCollection)
                .document(positiveStatementId)
                .delete { error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    promise(.success(()))
                }
        }
    }
}
