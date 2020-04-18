//
//  LoginVC.swift
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

class LoginVC: UIViewController {

    // MARK: - IB Outlets
    @IBOutlet weak var customFBLoginButton: UIButton!
    
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self

    }
    
    
    // MARK: - IB Actions
    @IBAction func customFBLoginButtonTapped(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["publicProfile", "email"], from: self) { [weak self] loginResult, _ in
            guard let weakSelf = self else { return }
            let accessTokenStringTest = AccessToken.current?.tokenString
            var name: String?
            var email: String?
            guard let accessTokenString: String = AccessToken.current?.tokenString else { return }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenStringTest!)
            let req = GraphRequest(graphPath: "me",
                                   parameters: ["fields":"email,name"],
                                   tokenString: accessTokenString,
                                   version: nil,
                                   httpMethod: .get)
            req.start(completionHandler: { (connection, result, error) in
                if error != nil {
                    print("error \(String(describing: error))")
                    return
                }
                guard let result = result else { return }
                guard let dic = result as? [String:String] else { return }
                name = dic["name"]
                email = dic["email"]
                guard let loginName = name, let loginMail = email else { return }
                weakSelf.signIn(credential: credential, userName: loginName, email: loginMail)
            })
        }
    }
    
    @IBAction func customGoogleLoginButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    // MARK: - Private Methods
    private func signIn(credential: AuthCredential, userName: String, email: String) {
        Auth.auth().signIn(with: credential) { (fireUser, fireError) in
            if let error = fireError {
                print(error)
                return
            }
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.moveUDDataToFirestoreIfNeeded()
            if let loginVC = appDelegate.window?.rootViewController! {
                let mainTabBarController: MainTabBarController = MainTabBarController()
                let leftMenuVC = UIStoryboard(name: "LeftMenu", bundle: nil).instantiateInitialViewController() as! LeftMenuVC
                leftMenuVC.userNameString = userName
                leftMenuVC.emailString = email
                appDelegate.createRootViewController(mainViewController: mainTabBarController, subViewController: leftMenuVC)

                loginVC.dismiss(animated: true, completion: nil)
            }
            if let loginVC = appDelegate.window?.rootViewController?.presentedViewController {
                loginVC.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

// MARK: - Extensions
extension LoginVC: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let authentication = user.authentication
        guard let auth = authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken,accessToken: auth.accessToken)
        self.signIn(credential: credential, userName: user.profile.name, email: user.profile.email)
    }
}

    



