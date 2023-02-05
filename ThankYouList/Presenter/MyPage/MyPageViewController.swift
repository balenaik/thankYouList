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

protocol MyPageRouter: Router {
    func dismiss()
    func switchToLogin()
    func presentConfirmDeleteAccount()
}

class MyPageViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var tableItems = [[TableItem]]()

    private var profile: Profile?

    var router: MyPageRouter?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        setupTableItems()
        loadMyProfile()
        logEvent()
    }
}

// MARK: - IBActions
extension MyPageViewController {
    @IBAction func tapClose(_ sender: Any) {
        router?.dismiss()
    }
}

// MARK: - private
private extension MyPageViewController {
    func setupView() {
        title = R.string.localizable.mypage_title()
        tableView.register(R.nib.myPageProfileCell)
    }

    func setupTableItems() {
        let myInfoSection = [TableItem(item: .myInformation, style: .profieInfo)]
        let additionalSection = [
            TableItem(item: .rate, style: .button),
            TableItem(item: .feedback, style: .button),
            TableItem(item: .privacyPolicy, style: .button)
        ]
        let logoutSection = [TableItem(item: .logout, style: .button)]
        let deleteAccountSection = [TableItem(item: .deleteAccount, style: .button)]
        tableItems.append(contentsOf: [myInfoSection, additionalSection, logoutSection, deleteAccountSection])
    }

    func loadMyProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let profile = Profile(name: user.displayName ?? "",
                              email: user.email ?? "",
                              imageUrl: user.providerData.first?.photoURL) // To get photoURL with Google Authentication since user.photoURL has 404 data
        self.profile = profile
    }

    func logEvent() {
        guard let user = Auth.auth().currentUser else { return }
        Analytics.logEvent(eventName: AnalyticsEventConst.showMyPage, userId: user.uid)
    }

    func showLogoutAlert() {
        let logoutAction = UIAlertAction(title: R.string.localizable.mypage_logout(),
                                         style: .destructive) { [weak self] _ in
            self?.logout()
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(),
                                         style: .cancel)
        router?.presentAlert(title: R.string.localizable.mypage_logout(),
                             message: R.string.localizable.mypage_logout_confirmation_message(),
                             actions: [logoutAction, cancelAction])
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            self.showLoginViewController()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func showDeleteAccountAlert() {
        let nextAction = UIAlertAction(title: R.string.localizable.next(),
                                       style: .destructive) { [weak self] _ in
            self?.presentConfirmDeleteAccount()
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(),
                                         style: .cancel)
        router?.presentAlert(title: R.string.localizable.mypage_delete_account(),
                             message: R.string.localizable.mypage_delete_account_confirmation_message(),
                             actions: [nextAction, cancelAction])
    }

    func presentConfirmDeleteAccount() {
        router?.presentConfirmDeleteAccount()
    }
}

// MARK: - Transition
private extension MyPageViewController {
    func showLoginViewController() {
        router?.switchToLogin()
    }
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
        case .button:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.myPageButtonCell, for: indexPath)!
            var configuration = cell.defaultContentConfiguration()
            configuration.text = item.item.titleText
            configuration.textProperties.color = item.item.titleColor ?? .text
            cell.contentConfiguration = configuration

            return cell
        case .profieInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.myPageProfileCell, for: indexPath)!
            if let profile = profile {
                cell.bind(profile: profile)
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension MyPageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = tableItems.getSafely(at: indexPath.section)?.getSafely(at: indexPath.row) else {
            return
        }
        switch item.item {
        case .logout:
            showLogoutAlert()
        case .deleteAccount:
            showDeleteAccountAlert()
        default:
            return
        }
    }
}
