//
//  MyPageButtonCell.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2022/05/14.
//  Copyright © 2022 Aika Yamada. All rights reserved.
//

import UIKit

private let buttonCornerRadius = CGFloat(16)
private let buttonBgColor = UIColor.white

class MyPageButtonCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!

    private var tableItem: MyPageViewController.TableItemType?

    override func awakeFromNib() {
        super.awakeFromNib()
        button.layer.cornerRadius = buttonCornerRadius
        button.setBackgroundColor(color: buttonBgColor.darken(), for: .highlighted)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
