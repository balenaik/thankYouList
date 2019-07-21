//
//  UserInfoLeftMenuTableViewCell.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/04/22.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit


class UserInfoLeftMenuTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var userNameString = ""
    var emailString = ""
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var userName: UILabel!
    
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Internal Methods
    func configureCell(userNameString: String, emailString: String) {
        userName.text = userNameString
        layoutIfNeeded()
    }
}
