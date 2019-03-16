//
//  LeftMenuViewController.swift
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

class LeftMenuViewController: UIViewController {
    
    enum MenuCategory: CaseIterable {
        case addThankYou
        case setting
        case logout
        
        func menuImageName() -> String {
            switch self {
            case .addThankYou:
                return "add_button"
            case .setting:
                return "setting"
            case .logout:
                return "ic_logout"
            }
        }
        
        func menuTitle() -> String {
            switch self {
            case .addThankYou:
                return NSLocalizedString("Add Thank You", comment: "")
            case .setting:
                return "Settings"
            case .logout:
                return NSLocalizedString("Logout", comment: "")
            }
        }
    }
    
    // MARK: - Properties
    var userNameString = ""
    var emailString = ""
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLabel.text = userNameString
    }
}

// MARK: - Private Methods
extension LeftMenuViewController {
    private func showAddThankYouViewController() {
        self.slideMenuController()?.closeLeft()
        let addThankYouDataVC = self.storyboard?.instantiateViewController(withIdentifier: "AddThankYouViewController") as! ThankYouList.AddThankYouViewController
        let navi = UINavigationController(rootViewController: addThankYouDataVC)
        self.slideMenuController()?.mainViewController?.present(navi, animated: true, completion: nil)
    }
    
    private func logout() {
        if Auth.auth().currentUser == nil { return }
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
}

extension LeftMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuCategory.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuCategory = MenuCategory.allCases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! LeftMenuCell
        cell.setMenuImage(imageName: menuCategory.menuImageName())
        cell.setMenuTitle(title: menuCategory.menuTitle())
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let menuCategory = MenuCategory.allCases[indexPath.row]
        switch menuCategory {
        case .addThankYou:
            showAddThankYouViewController()
        case .setting:
            break
        case .logout:
            logout()
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

extension LeftMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}


