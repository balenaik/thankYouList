//
//  ListSectionHeaderView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/02/02.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class ListSectionHeaderView: UITableViewHeaderFooterView {
    // MARK: -  Properties
    static let cellHeight = CGFloat(50)
    
    // MARK: - IBOutlets
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var bottomLine: UIView!
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Internal Methods
extension ListSectionHeaderView {

    @objc class func cellIdentifier() -> String {
        return String(describing: self)
    }
    
    func bind(sectionString: String) {
        sectionLabel.text = sectionString
    }
    
    func showBottomLine() {
        bottomLine.isHidden = false
    }
}
