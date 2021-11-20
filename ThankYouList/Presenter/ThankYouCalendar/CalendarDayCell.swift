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
