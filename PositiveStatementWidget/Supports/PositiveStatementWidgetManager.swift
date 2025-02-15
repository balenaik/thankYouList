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

    func getPositiveStatements() -> Future<[String], Error> {
        guard let currentUser = getAndUpdateCurrentUser() else {
            return Fail(error: PositiveStatementWidgetError.currentUserNotExist)
                .asFuture()
        }
        let userId = currentUser.uid
        let userId16string = String(userId.prefix(16))

        return Future<[String], Error> { promise in
            firestore
                .collection(FirestoreConst.usersCollecion)
                .document(userId)
                .collection(FirestoreConst.positiveStatementsCollection)
                .getDocuments{ snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    guard let documents = snapshot?.documents,
                          !documents.isEmpty else {
                        promise(.failure(PositiveStatementWidgetError.dataNotFound))
                        return
                    }

                    var statements = [String]()
                    for document in documents {
                        guard let encryptedValue = document.data()[encryptedValueKey] as? String else {
                            break
                        }

                        let decryptedValue = CryptoManager().decryptString(
                            encryptText: encryptedValue,
                            key: userId16string
                        )

                        statements.append(decryptedValue)
                    }
                    promise(.success(statements))
                }
        }
    }
}

private extension PositiveStatementWidgetManager {
    // currentUser sometimes doesn't reflect the user on the main app if the user signs in/out.
    // so we need to manually load the user from the main app and update the currentUser here.
    // https://stackoverflow.com/a/66561134
    func getAndUpdateCurrentUser() -> User? {
        let firebaseAuth = Auth.auth()

        let currentUserOnWidget = firebaseAuth.currentUser
        let currentUserOnMainApp = try? firebaseAuth.getStoredUser(forAccessGroup: AppConst.teamIdAndAccessGroup)

        guard let currentUserOnMainApp else {
            try? firebaseAuth.signOut()
            return nil
        }
        if currentUserOnMainApp.uid != currentUserOnWidget?.uid {
            firebaseAuth.updateCurrentUser(currentUserOnMainApp)
        }
        return currentUserOnMainApp
    }
}
