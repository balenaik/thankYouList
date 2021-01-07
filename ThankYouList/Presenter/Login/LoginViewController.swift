//
//  LoginViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/03/17.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices

private let loginButtonBorderWidth = CGFloat(0.5)
private let loginButtonBorderColor = UIColor.black.cgColor
private let loginButtonCornerRadius = CGFloat(10)
private let loginButtonHighlightedColor = UIColor.gray.withAlphaComponent(0.1)

private let loginButtonImageLeftInset = CGFloat(20)

private let appleProviderId = "apple.com"

class LoginViewController: UIViewController {

    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIButton!

    private var currentNonce: String?
    
    static func createViewController() -> UIViewController? {
        guard let viewController = R.storyboard.login().instantiateInitialViewController() else { return nil }
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        facebookLoginButton.setTitle(R.string.localizable.login_continue_with_facebook(), for: .normal)
        googleLoginButton.setTitle(R.string.localizable.login_continue_with_google(), for: .normal)
        appleLoginButton.setTitle(R.string.localizable.login_continue_with_apple(), for: .normal)
        
        facebookLoginButton.layer.cornerRadius = loginButtonCornerRadius
        facebookLoginButton.layer.borderWidth = loginButtonBorderWidth
        facebookLoginButton.layer.borderColor = loginButtonBorderColor
        googleLoginButton.layer.cornerRadius = loginButtonCornerRadius
        googleLoginButton.layer.borderWidth = loginButtonBorderWidth
        googleLoginButton.layer.borderColor = loginButtonBorderColor
        appleLoginButton.layer.cornerRadius = loginButtonCornerRadius
        appleLoginButton.layer.borderWidth = loginButtonBorderWidth
        appleLoginButton.layer.borderColor = loginButtonBorderColor

        facebookLoginButton.setBackgroundColor(color: loginButtonHighlightedColor, for: .highlighted)
        googleLoginButton.setBackgroundColor(color: loginButtonHighlightedColor, for: .highlighted)
        appleLoginButton.setBackgroundColor(color: loginButtonHighlightedColor, for: .highlighted)

        facebookLoginButton.adjustLoginInset()
        googleLoginButton.adjustLoginInset()
        appleLoginButton.adjustLoginInset()
    }
}

// MARK: - IB Actions
extension LoginViewController {
    @IBAction func tapFacebookLoginButton(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email"], from: self) { [weak self] loginResult, _ in
            guard let weakSelf = self else { return }
            guard let accessTokenString = AccessToken.current?.tokenString else {
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
            weakSelf.signIn(credential: credential)
        }
    }
    
    @IBAction func tapGoogleLoginButton(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }

    @IBAction func tapAppleLoginButton(_ sender: Any) {
        currentNonce = randomNonceString()
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
    private func signIn(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (fireUser, fireError) in
            if let error = fireError {
                print(error)
                return
            }
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.moveUDDataToFirestoreIfNeeded()
            if let loginViewController = appDelegate.window?.rootViewController {
                let mainTabBarController: MainTabBarController = MainTabBarController()
                appDelegate.createRootViewController(mainViewController: mainTabBarController)
                loginViewController.dismiss(animated: true, completion: nil)
            }
            if let loginViewController = appDelegate.window?.rootViewController?.presentedViewController {
                loginViewController.dismiss(animated: true, completion: nil)
            }
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
}

// MARK: - GIDSignInDelegate, GIDSignInUIDelegate
extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            showErrorAlert(title: R.string.localizable.error(),
                           message: R.string.localizable.error_authenticate())
            return
        }
        guard let auth = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken,accessToken: auth.accessToken)
        self.signIn(credential: credential)
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
            let credential = OAuthProvider.credential(withProviderID: appleProviderId,
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            signIn(credential: credential)
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

// MARK: - UIButton extension
fileprivate extension UIButton {
    func adjustLoginInset() {
        let originalImageEdgeInsets = self.imageEdgeInsets
        let originalTitleEdgeInsets = self.titleEdgeInsets
        let buttonWidth = self.frame.width
        let imageWidth = self.imageView?.frame.width ?? 0
        let textWidth = self.titleLabel?.frame.width ?? 0

        self.contentEdgeInsets = UIEdgeInsets.zero
        self.imageEdgeInsets = UIEdgeInsets(top: originalImageEdgeInsets.top,
                                            left: loginButtonImageLeftInset,
                                            bottom: originalImageEdgeInsets.bottom,
                                            right: buttonWidth - textWidth - imageWidth)
        self.titleEdgeInsets = UIEdgeInsets(top: originalTitleEdgeInsets.top,
                                            left: -imageWidth / 2,
                                            bottom: originalTitleEdgeInsets.bottom,
                                            right: 0)
    }
}
