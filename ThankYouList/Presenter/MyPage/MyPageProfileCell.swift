//
//  MyPageProfileCell.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/22.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import UIKit

class MyPageProfileCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    func bind(profile: Profile) {
        nameLabel.text = profile.name
        emailLabel.text = profile.emailAddress
        profileImageView.setImage(from: profile.imageUrl)
    }
}
