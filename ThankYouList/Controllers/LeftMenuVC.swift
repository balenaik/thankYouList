//
//  LeftMenuVC.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/03/17.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FBSDKLoginKit

class LeftMenuVC: UIViewController {
    
    enum MenuCategories {
        case addThankYou
        case logout
        
        func menuImageName() -> String {
            switch self {
            case .addThankYou:
                return "add_button"
            case .logout:
                return "ic_logout"
            default:
                return ""
            }
        }
        
        func menuTitle() -> String {
            switch self {
            case .addThankYou:
                return "Add Thank you"
            case .logout:
                return "logout"
            default:
                return ""
            }
        }
    }
    
    // MARK: - Properties
    var userNameString = ""
    var emailString = ""
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
}

extension LeftMenuVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoLeftMenuTableViewCell", for: indexPath) as! UserInfoLeftMenuTableViewCell
            cell.configureCell(userNameString: userNameString, emailString: emailString)
            return cell
        }
        var menuCategory = MenuCategories.logout
        if indexPath.row == 1 {
            menuCategory = MenuCategories.addThankYou
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! LeftMenuTableViewCell
        cell.setMenuImage(imageName: menuCategory.menuImageName())
        cell.setMenuTitle(title: menuCategory.menuTitle())
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Auth.auth().currentUser != nil else {
            return
        }        
        do {
            try Auth.auth().signOut()
            FBSDKAccessToken.setCurrent(nil)
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            self.present(loginVC!, animated: true)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
}

extension LeftMenuVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100
        }
        return 40
    }
}
