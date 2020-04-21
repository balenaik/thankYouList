//
//  MyPageViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/08.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class MyPageViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var tableItems = [[TableItem]]()

    static func createViewController() -> UIViewController? {
        guard let viewController = R.storyboard.myPage().instantiateInitialViewController() else { return nil }
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableItems()
    }
}

// MARK: - private
private extension MyPageViewController {
    func setupTableItems() {
        let myInfoSection = [TableItem(item: .myInformation, style: .profieInfo)]
        let logoutSection = [TableItem(item: .logout, style: .text)]
        tableItems.append(contentsOf: [myInfoSection, logoutSection])
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
            return UITableViewCell()
        }
    }
}

// MARK: - TableItem
extension MyPageViewController {
    struct TableItem {
        let item: TableItemType
        let style: TableItemStyle
    }

    enum TableItemType: Int {
        case myInformation
        case logout

        var titleText: String? {
            switch self {
            case .myInformation:
                return nil
            case .logout:
                return R.string.localizable.mypage_logout()
            }
        }
    }

    enum TableItemStyle {
        case profieInfo
        case text
    }
}
