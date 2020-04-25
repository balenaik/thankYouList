//
//  MyPageViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/08.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MyPageViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var tableItems = [[TableItem]]()

    private var profile: Profile?

    static func createViewController() -> UIViewController? {
        guard let viewController = R.storyboard.myPage().instantiateInitialViewController() else { return nil }
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        setupTableItems()
        loadMyProfile()
    }
}

// MARK: - private
private extension MyPageViewController {
    func setupView() {
        tableView.register(R.nib.myPageProfileCell)
    }

    func setupTableItems() {
        let myInfoSection = [TableItem(item: .myInformation, style: .profieInfo)]
        let logoutSection = [TableItem(item: .logout, style: .text)]
        tableItems.append(contentsOf: [myInfoSection, logoutSection])
    }

    func loadMyProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let profile = Profile(name: user.displayName ?? "",
                              emailAddress: user.email ?? "",
                              imageUrl: user.photoURL)
        self.profile = profile
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            self.showLoginViewController()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Transition
private extension MyPageViewController {
    func showLoginViewController() {
        if let loginViewController = LoginViewController.createViewController() {
            self.present(loginViewController, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate
extension MyPageViewController: UITableViewDelegate {
}

// MARK: - UITableViewDataSource
extension MyPageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableItems.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = tableItems[indexPath.section][indexPath.row]
        switch item.style {
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.myPageTextCell, for: indexPath)!
            cell.textLabel?.text = item.item.titleText
            return cell
        case .profieInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.myPageProfileCell, for: indexPath)!
            if let profile = profile {
                cell.bind(profile: profile)
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = tableItems[indexPath.section][indexPath.row]
        switch item.item {
        case .logout:
            logout()
        default:
            break
        }
    }
}
