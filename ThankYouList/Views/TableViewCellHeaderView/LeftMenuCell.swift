//
//  LeftMenuCell.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/05/06.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit


class LeftMenuCell: UITableViewCell {
    
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
    
    
    // MARK: - Override Methods
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: 0.2) {
            // Comment out because the animation part doesn't work
//            super.setHighlighted(highlighted, animated: animated)
            if highlighted {
                self.alpha = 0.8
                self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            } else {
                self.alpha = 1.0
                self.backgroundColor = UIColor.clear
            }
        }
    }
    
    // MARK: - Internal Methods
    func setMenuImage(imageName: String) {
        buttonImageView.image = UIImage(named: imageName)
    }
    
    func setMenuTitle(title: String) {
        menuTitle.text = title
    }
}
