//
//  TagsSettingViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/04/17.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class TagsSettingViewController: UIViewController {

    private var tags = [TagModel]()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        setupSetting()
    }

    private func setupSetting() {
        // test
        let tag = TagModel(color: UIColor.orange, name: "test")
        let tag2 = TagModel(color: UIColor.purple, name: "test2")
        let tag3 = TagModel(color: UIColor.purple, name: "test3")
        let tag4 = TagModel(color: UIColor.purple, name: "test4")
        let tag5 = TagModel(color: UIColor.purple, name: "test5")
        tags.append(tag)
        tags.append(tag2)
        tags.append(tag3)
        tags.append(tag4)
        tags.append(tag5)
    }

    @IBAction func addTest(_ sender: Any) {

    }

}

// MARK: - UITableViewDataSource
extension TagsSettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.cellIdentifier, for: indexPath) as! TagSettingCell
        let tag = tags[indexPath.row]
        cell.bind(tag: tag)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tag = tags[indexPath.row]
        let tagSettingViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "EditTagViewController") as!  EditTagViewController
        self.navigationController?.pushViewController(tagSettingViewController, animated:  true)
    }
}

extension TagsSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
