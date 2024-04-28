//
//  PositiveStatementRepository.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/04/09.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import FirebaseFirestore

protocol PositiveStatementRepository {
    func createPositiveStatement(positiveStatement: String, userId: String) -> Future<Void, Error>
}

struct DefaultPositiveStatementRepository: PositiveStatementRepository {

    let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
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
