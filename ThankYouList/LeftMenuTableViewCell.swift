//
//  LeftMenuTableViewCell.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/05/06.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit


class LeftMenuTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var menuTitle: UILabel!
    @IBOutlet weak var buttonImageView: UIImageView!
    
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - View LifeCycles
    override func layoutSubviews() {
        buttonImageView.image = buttonImageView.image?.withRenderingMode(.alwaysTemplate)
    }
}
