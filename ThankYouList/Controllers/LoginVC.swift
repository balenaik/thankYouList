//
//  LoginVC.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/03/17.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginVC: UIViewController {

    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fbLoginButton.delegate = UIApplication.shared.delegate as! AppDelegate as! FBSDKLoginButtonDelegate
    }

}


