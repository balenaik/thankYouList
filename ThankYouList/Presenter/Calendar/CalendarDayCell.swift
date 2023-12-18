//
//  CalendarDayCell.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2017/09/04.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarDayCell: JTAppleCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    
    @IBOutlet weak var oneDotView: UIStackView!
    @IBOutlet weak var twoDotsView: UIStackView!
    @IBOutlet weak var threeDotsView: UIStackView!
    @IBOutlet weak var dotsAndPlusView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedView.backgroundColor = UIColor.primary200.withAlphaComponent(0.6)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        selectedView.layer.cornerRadius = selectedView.bounds.height / 2
    }
}

// MARK: - Public
extension CalendarDayCell {
    func bind(cellState: CellState, thankYouCount: Int) {
        var dateLabelColor: UIColor
        switch cellState.dateBelongsTo {
        case .thisMonth:
            dateLabelColor = .text
        default:
            dateLabelColor = .black26
        }
        if Calendar.current.isDateInToday(cellState.date) {
            dateLabelColor = .primary900
        }
        dateLabel.text = cellState.text
        dateLabel.textColor = dateLabelColor

        bindThankYouCount(count: thankYouCount)
    }

    func bindSelection(isSelected: Bool) {
        selectedView.isHidden = !isSelected
    }
}

// MARK: - Private
private extension CalendarDayCell {
    func bindThankYouCount(count: Int) {
        oneDotView.isHidden = count != 1
        twoDotsView.isHidden = count != 2
        threeDotsView.isHidden = count != 3
        dotsAndPlusView.isHidden = count < 4
    }
}
