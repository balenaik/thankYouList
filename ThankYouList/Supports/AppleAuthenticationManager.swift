//
//  AppleAuthenticationManager.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/03/26.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Combine
import FirebaseAuth
import AuthenticationServices

enum AppleAuthenticationError: Error {
    case credentialNotFound
    case tokenNotFound
}

// Needed to be a class to inherit ASAuthorizationControllerDelegate
class AppleAuthenticationManager: NSObject, ASAuthorizationControllerDelegate {
    private var currentNonce: String?
    private let authorizationDidComplete = PassthroughSubject<ASAuthorization, Error>()

    func signInWithApple() -> Future<AuthCredential, Error> {
        currentNonce = String.randomNonce()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()

        return authorizationDidComplete
            .tryMap { [weak self] authorization in
                guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                    throw AppleAuthenticationError.credentialNotFound
                }
                guard let token = credential.identityToken,
                      let tokenString = String(data: token, encoding: .utf8) else {
                    throw AppleAuthenticationError.tokenNotFound
                }
                return OAuthProvider.credential(
                    providerID: .apple,
                    idToken: tokenString,
                    rawNonce: self?.currentNonce ?? ""
                )
            }
            .asFuture()
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        authorizationDidComplete.send(authorization)
    }
}
