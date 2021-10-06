//
//  ThankYouCell.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/01/27.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

private let thankYouViewCornerRadius = CGFloat(8)
private let thankYouViewShadowColor = UIColor.black.withAlphaComponent(0.26)
private let thankYouViewShadowOpacity = Float(0.3)
private let thankYouViewShadowOffset = CGSize(width: 0, height: 5)

class ThankYouCell: UITableViewCell {
    
    private var thankYouData: ThankYouData?
    @IBOutlet private weak var thankYouView: UIView!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var monthLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        thankYouView.layer.cornerRadius = thankYouViewCornerRadius
        thankYouView.layer.shadowColor = thankYouViewShadowColor.cgColor
        thankYouView.layer.shadowOpacity = thankYouViewShadowOpacity
        thankYouView.layer.shadowOffset = thankYouViewShadowOffset
    }
    
    @objc class func cellIdentifier() -> String {
        return String(describing: self)
    }
    
    func bind(thankYouData: ThankYouData) {
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
