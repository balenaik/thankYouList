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

protocol MyPageButtonCellDelegate: class {
    func myPageButtonCellDidtapButton(tableItem: MyPageViewController.TableItemType?)
}

class MyPageButtonCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!

    private var tableItem: MyPageViewController.TableItemType?
    weak var delegate: MyPageButtonCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        button.layer.cornerRadius = buttonCornerRadius
        button.setBackgroundColor(color: buttonBgColor.darken(), for: .highlighted)
    }
}

private extension MyPageButtonCell {
    @IBAction func buttonDidTap(_ sender: Any) {
        delegate?.myPageButtonCellDidtapButton(tableItem: tableItem)
    }
}

extension MyPageButtonCell {
    func setTableItem(_ item: MyPageViewController.TableItemType) {
        self.tableItem = item
        button.setTitle(item.titleText, for: .normal)
        button.setTitleColor(item.titleColor, for: .normal)
    }
}
