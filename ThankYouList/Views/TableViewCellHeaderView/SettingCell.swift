//
//  SettingCell.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/03/23.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowRightIcon: UIImageView!

    static var cellIdentifier: String {
        return String(describing: self)
    }

    func bind(title: String) {
        titleLabel.text = title
    }
}
