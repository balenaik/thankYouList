//
//  PositiveStatementWidgetManager.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/11/30.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import Firebase
import FirebaseFirestore
import SharedResources

private let encryptedValueKey = "encryptedValue"
private let createdDateKey = "createdDate"

struct PositiveStatementWidgetManager {
    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    func getPositiveStatementEntries() -> Future<[PositiveStatementEntry], Error> {
        guard let currentUser = Auth.auth().currentUser else {
            return Fail(error: PositiveStatementWidgetError.currentUserNotExist)
                .asFuture()
        }
        let userId = currentUser.uid
        let userId16string = String(userId.prefix(16))

        return Future<[PositiveStatementEntry], Error> { promise in
            firestore
                .collection(FirestoreConst.usersCollecion)
                .document(userId)
                .collection(FirestoreConst.positiveStatementsCollection)
                .getDocuments{ snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    guard let documents = snapshot?.documents else {
                        promise(.failure(PositiveStatementWidgetError.dataNotFound))
                        return
                    }

                    var entries = [PositiveStatementEntry]()
                    var displayDate = Date()

                    for document in documents {
                        guard let encryptedValue = document.data()[encryptedValueKey] as? String else {
                            break
                        }

                        let decryptedValue = CryptoManager().decryptString(
                            encryptText: encryptedValue,
                            key: userId16string
                        )
                        let positiveStatement = PositiveStatementEntry(
                            date: displayDate,
                            positiveStatement: decryptedValue
                        )

                        entries.append(positiveStatement)

                        displayDate = Calendar.current.date(byAdding: .minute, value: 1, to: displayDate) ?? displayDate
                    }
                    promise(.success(entries))
                }
        }
    }
}
