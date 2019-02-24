//
//  ThankYouCell.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/01/27.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class ThankYouCell: UITableViewCell {
    
    var thankYouData: ThankYouData?
    @IBOutlet weak var thankYouView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    @objc class func cellIdentifier() -> String {
        return String(describing: self)
    }
    
    func bind(thankYouData: ThankYouData) {
        self.backgroundColor = UIColor.clear
        thankYouView.layer.shadowColor = UIColor.lightGray.cgColor
        self.thankYouData = thankYouData
        contentLabel.text = thankYouData.value
        dayLabel.text = thankYouData.date.toDayString()
        monthLabel.text = thankYouData.date.toMonthEnglish3lettersString()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setSelected(highlighted, animated: animated)
        UIView.animate(withDuration: 0.1) {
            self.thankYouView.backgroundColor = highlighted
                ? UIColor.lightGray.withAlphaComponent(0.1) : UIColor.white
        }
    }
}
