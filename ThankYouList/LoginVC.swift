//
//  LoginVC.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/03/17.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import UIKit
import FacebookLogin

class LoginVC: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = LoginButton(readPermissions: [ .email ])
        loginButton.delegate = UIApplication.shared.delegate as! AppDelegate
        loginButton.center = view.center
        view.addSubview(loginButton)
    }

}


