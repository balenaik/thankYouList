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
import GoogleSignIn

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
                return NSLocalizedString("Add Thank You", comment: "")
            case .logout:
                return NSLocalizedString("Logout", comment: "")
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
    
    // MARK: - View LifeCycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    
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
        if indexPath.row == 0 {
            return
        } else if indexPath.row == 1 {
            self.slideMenuController()?.closeLeft()
            let addThankYouDataVC = self.storyboard?.instantiateViewController(withIdentifier: "addThankYouDataVC") as! ThankYouList.AddThankYouDataVC
            let navi = UINavigationController(rootViewController: addThankYouDataVC)
            self.slideMenuController()?.mainViewController?.present(navi, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        if Auth.auth().currentUser == nil {
            return
        }        
        do {
            try Auth.auth().signOut()
            FBSDKAccessToken.setCurrent(nil)
            GIDSignIn.sharedInstance().signOut()
            GIDSignIn.sharedInstance().disconnect()
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            self.present(loginVC!, animated: true)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setHighlighted(true, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setHighlighted(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setHighlighted(false, animated: true)
    }
}

extension LeftMenuVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 174
        }
        return 50
    }
}


