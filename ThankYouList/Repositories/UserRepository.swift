//
//  UserRepository.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/04.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import FirebaseAuth
import Combine
import GoogleSignIn
import FBSDKCoreKit

enum UserRepositoryError: Error {
    case currentUserNotExist
    case authProviderNotFound
    case tokenNotFound
}

enum AuthProvider: String {
    case facebook = "facebook.com"
    case google = "google.com"
    case apple = "apple.com"
}

protocol UserRepository {
    func isLoggedIn() -> Bool
    func getUserProfile() -> Future<Profile, Error>
    func reAuthenticateToProviderIfNeeded() -> Future<Void, Error>
    func deleteAccount() -> Future<Void, Error>
}

struct DefaultUserRepository: UserRepository {
    private let appleAuthenticationManager = AppleAuthenticationManager()

    func isLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }

    func getUserProfile() -> Future<Profile, Error> {
        return Future<Profile, Error> { promise in
            guard let user = Auth.auth().currentUser else {
                return promise(.failure(UserRepositoryError.currentUserNotExist))
            }
            var email = user.email
            if email == nil {
                // For accounts whose email is not correctly registered to Firebase
                // e.g. The same email has been already registered in another account by other method
                email = user.providerData.first?.email
            }
            let profile = Profile(id: user.uid,
                                  name: user.displayName ?? "",
                                  email: email ?? "",
                                  imageUrl: user.providerData.first?.photoURL) // To get photoURL with Google Authentication since user.photoURL has 404 data
            return promise(.success(profile))
        }
    }

    func reAuthenticateToProviderIfNeeded() -> Future<Void, Error> {
        return Future<Void, Error> { promise in
            let authProvider = self.getUsersAuthProvider()
            switch authProvider {
            case .google:
                GIDSignIn.sharedInstance.restorePreviousSignIn { _, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    promise(.success(()))
                }
            default:
                return
            }
        }
    }

    func deleteAccount() -> Future<Void, Error> {
        return getCredential()
            .flatMap { credential -> Future<Void, Error> in
                self.reauthenticateAndDeleteAccount(credential: credential)
            }
            .eraseToAnyPublisher()
            .asFuture()
    }
}

private extension DefaultUserRepository {
    func getUsersAuthProvider() -> AuthProvider? {
        guard let providerId = Auth.auth().currentUser?.providerData.first?.providerID,
              let authProvider = AuthProvider(rawValue: providerId) else { return nil }
        return authProvider
    }

    func getCredential() -> Future<AuthCredential, Error> {
        guard let provider = getUsersAuthProvider() else {
            return Fail(error: UserRepositoryError.authProviderNotFound)
                .asFuture()
        }
        let authCredential: AuthCredential
        switch provider {
        case .google:
            guard let currentUser = GIDSignIn.sharedInstance.currentUser,
                  let idToken = currentUser.idToken else {
                return Fail(error: UserRepositoryError.tokenNotFound)
                    .asFuture()
            }
            let accessToken = currentUser.accessToken
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: accessToken.tokenString)
            authCredential = credential
        case .facebook:
            guard let tokenString = AccessToken.current?.tokenString else {
                return Fail(error: UserRepositoryError.tokenNotFound)
                    .asFuture()
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
            authCredential = credential
        case .apple:
            return appleAuthenticationManager
                .signInWithApple()
                .asFuture()
        }
        return Just(authCredential).setFailureType(to: Error.self).asFuture()
    }

    func reauthenticateAndDeleteAccount(credential: AuthCredential) -> Future<Void, Error> {
        guard let user = Auth.auth().currentUser else {
            return Fail(error: UserRepositoryError.currentUserNotExist).asFuture()
        }
        return Future<Void, Error> { promise in
            user.reauthenticate(with: credential) { _, reAuthenticateError in
                if let reAuthenticateError = reAuthenticateError {
                    promise(.failure(reAuthenticateError))
                }
                user.delete() { deleteError in
                    if let deleteError = deleteError {
                        promise(.failure(deleteError))
                    }
                    promise(.success(()))
                }
            }
        }
    }
}
