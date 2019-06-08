//
//  TagSettingCell.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/04/17.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

class TagSettingCell: UITableViewCell {

    @IBOutlet weak var dotView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var arrowRightIcon: UIImageView!

    static var cellIdentifier: String {
        return String(describing: self)
    }

    func bind(title: String) {
        nameLabel.text = title
    }
}
