//
//  MyPageCoordinator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/10.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

private let appStoreReviewUrl = "https://apps.apple.com/app/id1271631134?action=write-review"

class MyPageCoordinator: Coordinator {

    var routingType: RoutingType
    weak var viewController: UIViewController?

    init(presentingViewController: UIViewController) {
        routingType = RoutingType.modal(presentingViewController: presentingViewController)
    }

    func start() {
        guard let viewController = R.storyboard.myPage.instantiateInitialViewController() else {
            return
        }
        viewController.router = self
        let navigationController = UINavigationController(rootViewController: viewController)
        self.viewController = navigationController
        navigationController.modalPresentationStyle = .pageSheet
        routingType.previousViewController?.present(navigationController, animated: true)
    }
}

extension MyPageCoordinator: MyPageRouter {
    func dismiss() {
        viewController?.dismiss(animated: true)
    }

    func switchToLogin() {
        guard let window = UIApplication.shared.windows.first(where: \.isKeyWindow) else {
            return
        }
        let loginCoordinator = LoginCoordinator(window: window)
        loginCoordinator.start()
    }

    func openAppStoreReview() {
        guard let appStoreUrl = URL(string: appStoreReviewUrl) else { return }
        UIApplication.shared.open(appStoreUrl)
    }

    func presentPrivacyPolicy() {
        guard let privacyPolicyUrl = URL(string: R.string.localizable.privacy_policy_url()) else { return }
        let safariViewController = SFSafariViewController(url: privacyPolicyUrl)
        viewController?.present(safariViewController, animated: true)
    }

    func presentConfirmDeleteAccount() {
        guard let viewController = viewController else { return }
        let coordinator = ConfirmDeleteAccountCoordinator(presentingViewController: viewController)
        coordinator.start()
    }

    func openDefaultMailAppIfAvailable(to: String, subject: String) -> Bool {
        guard MFMailComposeViewController.canSendMail(),
              // TODO: Wanna fix how to access MyPageVC
              let navigationController = viewController as? UINavigationController,
              let myPageViewController = navigationController.viewControllers.first else {
            return false
        }
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = myPageViewController as? MFMailComposeViewControllerDelegate
        mail.setToRecipients([to])
        mail.setSubject(subject)
        viewController?.present(mail, animated: true)
        return true
    }

    func openGmailAppIfAvailable(to: String, subject: String) -> Bool {
        guard let encodedSubject = subject
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "googlegmail://co?to=\(to)&subject=\(encodedSubject)"),
              UIApplication.shared.canOpenURL(url) else {
            return false
        }
        UIApplication.shared.open(url)
        return true
    }
}
