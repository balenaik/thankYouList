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
        oneDotView.isHidden = true
        twoDotsView.isHidden = true
        threeDotsView.isHidden = true
        dotsAndPlusView.isHidden = true

        switch count {
        case 0:
            break
        case 1:
            oneDotView.isHidden = false
        case 2:
            twoDotsView.isHidden = false
        case 3:
            threeDotsView.isHidden = false
        default:
            dotsAndPlusView.isHidden = false
        }
    }
}
