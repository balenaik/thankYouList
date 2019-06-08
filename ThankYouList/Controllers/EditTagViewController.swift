//
//  EditTagViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/05/03.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

class EditTagViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - UITableViewDataSource
extension EditTagViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditTagNameCell.cellIdentifier, for: indexPath) as! EditTagNameCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TagColorCell", for: indexPath) as! TagSettingCell
            return cell
        default:
            return UITableViewCell()
        }

    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let setting = settings[indexPath.section]
//        switch setting.setting {
//        case .tags:
//            showTagSettingViewController()
//        case .sendAppReview:
//            //            transitionAppReview()
//            break
//        case .logout:
//            //            logout()
//            break
//        }
//
//    }
}

extension EditTagViewController: UITableViewDelegate {

}
