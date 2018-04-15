//
//  LoginVC.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/03/17.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import FirebaseAuth
import FacebookCore
import FacebookLogin
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
        loginManager.logIn(readPermissions: [ ReadPermission.publicProfile ], viewController: self) { [weak self] loginResult in
            guard let weakSelf = self else { return }
            switch loginResult {
            case .success:
                let accessToken = AccessToken.current
                guard let accessTokenString: String = accessToken?.authenticationToken else { return }
                let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                weakSelf.signIn(credential: credential)
            default:
                return
            }
        }
    }
    
    @IBAction func customGoogleLoginButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    // MARK: - Private Methods
    private func signIn(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (fireUser, fireError) in
            if let error = fireError {
                // いい感じのエラー処理
                return
            }
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            if let loginVC = appDelegate.window?.rootViewController! {
                let mainTabBarController: MainTabBarController = MainTabBarController()
                let leftMenuVC = self.storyboard?.instantiateViewController(withIdentifier: "LeftMenuVC")
                let rootViewController = SlideMenuController(mainViewController: mainTabBarController, leftMenuViewController: leftMenuVC!)
                SlideMenuOptions.contentViewDrag = true
                appDelegate.window?.rootViewController = rootViewController
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
        self.signIn(credential: credential)
    }
}
    
    



