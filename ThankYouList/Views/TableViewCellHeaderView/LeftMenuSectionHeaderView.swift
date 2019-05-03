//
//  LeftMenuSectionHeaderView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/03/16.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

class LeftMenuSectionHeaderView: UITableViewHeaderFooterView {
    // MARK: -  Properties
    static let cellHeight = CGFloat(16)
}

// MARK: - Internal Methods
extension LeftMenuSectionHeaderView {
    
    static var cellIdentifier: String {
        return String(describing: self)
    }
    
    static func build() -> UINib {
        return UINib(nibName: self.cellIdentifier, bundle: nil)
    }
}
