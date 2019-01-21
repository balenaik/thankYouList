//
//  SettingHeaderView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/01/02.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class SettingHeaderView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var headerTitle: UILabel!
    
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = Bundle.main.loadNibNamed("SettingHeaderView", owner: self, options: nil)?.first as! UIView
        self.addSubview(view)
    }
    
    
    // MARK: - Internal Methods
    func setHeaderTitle(_ title: String) {
        headerTitle.text = title
    }
    
    func hideHeaderTitle() {
        headerTitle.isHidden = true
    }
}
