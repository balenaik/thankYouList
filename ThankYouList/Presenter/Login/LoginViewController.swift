//
//  LoginViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/03/17.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import AuthenticationServices
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import SharedResources
import UIKit
import WidgetKit

protocol LoginRouter {
    func switchToMainTabBar()
}

class LoginViewController: UIViewController {

    @IBOutlet weak var facebookLoginButton: LoginContinueButton!
    @IBOutlet weak var googleLoginButton: LoginContinueButton!
    @IBOutlet weak var appleLoginButton: LoginContinueButton!

    private var currentNonce: String?

    var router: LoginRouter?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

// MARK: - IB Actions
extension LoginViewController {
    @IBAction func tapFacebookLoginButton(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email"], from: self) { [weak self] loginResult, _ in
            guard let self = self else { return }
            guard let accessTokenString = AccessToken.current?.tokenString else {
                return
            }
            GraphRequest(graphPath: "me",
                         parameters: ["fields" : "email"]).start { _, result, _ in
                let dict = result as? [String: String]
                let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                self.signIn(credential: credential, email: dict?["email"])
            }
        }
    }
    
    @IBAction func tapGoogleLoginButton(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] (result, error) in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                self.showErrorAlert(title: R.string.localizable.error(),
                                    message: R.string.localizable.error_authenticate())
                return
            }
            guard let idToken = result?.user.idToken,
                  let accessToken = result?.user.accessToken else { return }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: accessToken.tokenString)
            self.signIn(credential: credential,
                        email: result?.user.profile?.email)
        }
    }

    @IBAction func tapAppleLoginButton(_ sender: Any) {
        currentNonce = String.randomNonce()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// MARK: - Private Methods
private extension LoginViewController {
    func setupView() {
        facebookLoginButton.setTitle(R.string.localizable.login_continue_with_facebook(), for: .normal)
        googleLoginButton.setTitle(R.string.localizable.login_continue_with_google(), for: .normal)
        appleLoginButton.setTitle(R.string.localizable.login_continue_with_apple(), for: .normal)
    }

    func signIn(credential: AuthCredential,
                name: String? = nil,
                email: String? = nil) {
        Auth.auth().signIn(with: credential) { [weak self] (user, error) in
            if let error = error {
                print(error)
                return
            }
            if let name = name {
                self?.updateUserProfile(name: name)
            }
            if let email = email {
                self?.updateUserEmail(email: email)
            }
            WidgetCenter.shared.reloadTimelines(ofKind: AppConst.positiveStatementWidgetKind)
            self?.router?.switchToMainTabBar()
        }
    }

    func updateUserProfile(name: String) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges()
    }

    func updateUserEmail(email: String) {
        Auth.auth().currentUser?.updateEmail(to: email, completion: nil)
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                showErrorAlert(title: R.string.localizable.error(),
                               message: R.string.localizable.error_authenticate())
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(providerID: .apple,
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            var name: String?
            if let fullName = appleIDCredential.fullName {
                if let givenName = fullName.givenName {
                    name = givenName
                }
                if let familyName = fullName.familyName {
                    name = name ?? "" + (" " + familyName)
                }
            }
            name = (name?.isEmpty ?? true) ? nil : name
            let email = appleIDCredential.email
            self.signIn(credential: credential, name: name, email: email)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showErrorAlert(title: R.string.localizable.error(),
                       message: R.string.localizable.error_authenticate())
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
