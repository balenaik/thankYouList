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

    
    @IBOutlet weak var customFBLoginButton: UIButton!
    @IBOutlet weak var googleLoginView: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().signIn()

    }
    
    @IBAction func customFBLoginButtonTapped(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ ReadPermission.publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .success:
                let accessToken = AccessToken.current
                guard let accessTokenString: String = accessToken?.authenticationToken else { return }
                
                let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                // Firebaseにcredentialを渡してlogin
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
                
            default:
                return
            }
        }
    }
    

}


extension LoginVC: GIDSignInUIDelegate {
    
}


