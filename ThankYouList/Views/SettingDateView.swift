//
//  SettingDateView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/01/05.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class SettingDateView: UIView {
    
    // MARK: - Constants
    fileprivate let DATELABEL_TRAILING_CONSTRAINT = CGFloat(-10)
    
    // MARK: - Properties
    private let dateLabel = UILabel()
    private let dateFormatter = DateFormatter()
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateLabel.textAlignment = .right
        dateLabel.baselineAdjustment = .alignCenters
        
        self.addSubview(dateLabel)
        setConstraints()        
    }
    
    func setConstraints() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: DATELABEL_TRAILING_CONSTRAINT).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        dateLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: DATELABEL_TRAILING_CONSTRAINT).isActive = true
        dateLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
}

// MARK: - Internal Methods
extension SettingDateView {
    func getDateString() -> String? {
        return dateLabel.text
    }
    
    func setDate(_ date: Date) {
        let dateValue = dateFormatter.string(from: date)
        dateLabel.text = dateValue
    }
}
