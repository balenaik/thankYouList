//
//  SettingsViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/03/21.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {

    private var settings = [SettingModel]()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        setupSetting()

        self.navigationController?.navigationBar.barTintColor = TYLColor.navigationBarBgColor
        self.navigationController?.navigationBar.tintColor = TYLColor.navigationBarTextColor
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : TYLColor.navigationBarTextColor
        ]
    }

    private func setupSetting() {
        var settings = [SettingModel]()
        for setting in SettingModel.Setting.allCases {
            let menu = SettingModel(setting: setting)
            settings.append(menu)
        }
        self.settings = settings
    }
}

// MARK: - IBAction
extension SettingsViewController {
    @IBAction func tapCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Private Methods
extension SettingsViewController {
    private func showTagSettingViewController() {
//        let tagsSettingViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "TagsSettingViewController") as!  TagsSettingViewController
//        self.navigationController?.pushViewController(tagsSettingViewController, animated:  true)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.cellIdentifier, for: indexPath) as! SettingCell
        let setting = settings[indexPath.section]
        cell.bind(title: setting.setting.title)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let setting = settings[indexPath.section]
        switch setting.setting {
        case .tags:
            showTagSettingViewController()
        case .sendAppReview:
//            transitionAppReview()
            break
        case .logout:
//            logout()
            break
        }

    }
}

extension SettingsViewController: UITableViewDelegate {

}
