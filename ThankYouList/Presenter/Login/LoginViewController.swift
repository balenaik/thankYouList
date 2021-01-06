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

class LoginViewController: UIViewController {

    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIButton!
    
    static func createViewController() -> UIViewController? {
        guard let viewController = R.storyboard.login().instantiateInitialViewController() else { return nil }
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        facebookLoginButton.setTitle(R.string.localizable.login_continue_with_facebook(), for: .normal)
        googleLoginButton.setTitle(R.string.localizable.login_continue_with_google(), for: .normal)
        appleLoginButton.setTitle(R.string.localizable.login_continue_with_apple(), for: .normal)
    }
}
    
// MARK: - IB Actions
extension LoginViewController {
    @IBAction func customFBLoginButtonTapped(_ sender: Any) {
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
    
    @IBAction func customGoogleLoginButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
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
    
}

// MARK: - GIDSignInDelegate, GIDSignInUIDelegate
extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let auth = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken,accessToken: auth.accessToken)
        self.signIn(credential: credential)
    }
}

    



