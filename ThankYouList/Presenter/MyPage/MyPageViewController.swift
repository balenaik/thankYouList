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
import MessageUI

private let feedbackTo = "balenaik+thankyoulist-feedback@gmail.com"
private let feedbackSubject = "Thank You List Feedback"

protocol MyPageRouter: Router {
    func dismiss()
    func switchToLogin()
    func openAppStoreReview()
    func presentPrivacyPolicy()
    func presentConfirmDeleteAccount()
    func openDefaultMailAppIfAvailable(to: String, subject: String) -> Bool
    func openGmailAppIfAvailable(to: String, subject: String) -> Bool
}

class MyPageViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var tableItems = [[TableItem]]()
    private var profile: Profile?

    private let analyticsManager = DefaultAnalyticsManager()
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
        let profile = Profile(id: user.uid,
                              name: user.displayName ?? "",
                              email: user.email ?? "",
                              imageUrl: user.providerData.first?.photoURL) // To get photoURL with Google Authentication since user.photoURL has 404 data
        self.profile = profile
    }

    func logEvent() {
        guard let user = Auth.auth().currentUser else { return }
        analyticsManager.logEvent(eventName: AnalyticsEventConst.showMyPage, userId: user.uid)
    }

    func showRating() {
        router?.openAppStoreReview()
    }

    func showFeedbackAlert() {
        guard let router = router else { return }
        if router.openDefaultMailAppIfAvailable(to: feedbackTo,
                                                subject: feedbackSubject) {
            return
        }
        if router.openGmailAppIfAvailable(to: feedbackTo,
                                          subject: feedbackSubject) {
            return
        }
        router.presentAlert(
            title: R.string.localizable.mypage_feedback_unable_to_send_email_title(),
            message: R.string.localizable.mypage_feedback_unable_to_send_email_message()
        )
    }

    func showPrivacyPolicy() {
        router?.presentPrivacyPolicy()
    }

    func showLogoutAlert() {
        let logoutAction = AlertAction(title: R.string.localizable.mypage_logout(),
                                       style: .destructive) { [weak self] in
            self?.logout()
        }
        let cancelAction = AlertAction(title: R.string.localizable.cancel(),
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
        let nextAction = AlertAction(title: R.string.localizable.next(),
                                     style: .destructive) { [weak self] in
            self?.presentConfirmDeleteAccount()
        }
        let cancelAction = AlertAction(title: R.string.localizable.cancel(),
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
        guard let item = tableItems.getSafely(at: indexPath.section)?.getSafely(at: indexPath.row) else {
            return UITableViewCell()
        }

        switch item.style {
        case .button:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.myPageButtonCell, for: indexPath) else {
                return UITableViewCell()
            }
            var configuration = cell.defaultContentConfiguration()
            configuration.text = item.item.titleText
            configuration.textProperties.color = item.item.titleColor ?? .text
            configuration.textProperties.font = UIFont.regularAvenir(ofSize: 16)
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
        case .rate:
            showRating()
        case .feedback:
            showFeedbackAlert()
        case .privacyPolicy:
            showPrivacyPolicy()
        case .logout:
            showLogoutAlert()
        case .deleteAccount:
            showDeleteAccountAlert()
        default:
            break
        }
    }
}

extension MyPageViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }
}
