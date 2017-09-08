//
//  CalendarVC.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2017/09/04.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarVC: UIViewController {
    let formatter = DateFormatter()
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearMonth: UILabel!
    
    
    // Get the singleton
    let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
    
    // Set colors
    let navigationBarBgColor = UIColor(colorWithHexValue: 0xfff8e8)
    let navigationBarTextColor = UIColor(colorWithHexValue: 0xfe939d)
    let grayColor = UIColor(colorWithHexValue: 0x5a5a5a)
    let highGrayColor = UIColor(colorWithHexValue: 0xc8c8c8)
    let pinkColor = UIColor(colorWithHexValue: 0xfcb5b5)

    
    @IBAction func backToList(_ sender: Any) {
        // Return
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup the background color for navigationbar
        self.navigationController?.navigationBar.barTintColor = navigationBarBgColor
        
        // setup the text color for navagationbar
        self.navigationController?.navigationBar.tintColor = navigationBarTextColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : navigationBarTextColor]

        // Set the opening month when the screen is showed
        calendarView.scrollToDate(Date(), animateScroll: false)
        
        setupCalendarView()
        
        //self.getThankYou()
        
        
        DispatchQueue.main.async {
            //self.calendarView.reloadData()
        }
    }

    func setupCalendarView() {
        // Setup calendar spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        // Setup labels
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
    }
    
    /* Cell configuration functions */
    func configureCell(cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCell else { return }
        formatter.dateFormat = "yyyy MM dd"
        
        handleCellSelected(view: validCell, cellState: cellState)
        handleCellTextColor(view: validCell, cellState: cellState)
        handleCellEvents(view: validCell, cellState: cellState)
        
    }
    
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCell else { return }
        
        if cellState.isSelected {
            validCell.dateLabel.textColor = grayColor
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = grayColor
            } else {
                validCell.dateLabel.textColor = highGrayColor
            }
        }

        // Change the text color on today
        let todaysDate = Date()
        formatter.dateFormat = "yyyy MM dd"
        
        let todaysDateString = formatter.string(from: todaysDate)
        let monthDateString = formatter.string(from: cellState.date)
        
        if todaysDateString == monthDateString {
            validCell.dateLabel.textColor = pinkColor
        }
    }
    
        
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCell else { return }
        if validCell.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
    }
    
    func handleCellEvents(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCell else { return }
        
        self.formatter.dateFormat = "yyyy/MM/dd"
        if thankYouDataSingleton.thankYouDataList.filter({$0.thankYouDate == formatter.string(from: cellState.date)}).count == 1 {
            validCell.oneDotView.isHidden = false
        } else if thankYouDataSingleton.thankYouDataList.filter({$0.thankYouDate == formatter.string(from: cellState.date)}).count == 2 {
            validCell.twoDotsView.isHidden = false
        } else if thankYouDataSingleton.thankYouDataList.filter({$0.thankYouDate == formatter.string(from: cellState.date)}).count == 3 {
            validCell.threeDotsView.isHidden = false
        } else if thankYouDataSingleton.thankYouDataList.filter({$0.thankYouDate == formatter.string(from: cellState.date)}).count >= 4 {
            validCell.dotsAndPlusView.isHidden = false
        }
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        self.formatter.dateFormat = "MMMM yyyy"
        self.yearMonth.text = self.formatter.string(from: date)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CalendarVC: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from:"2017 01 01")!
        let endDate = formatter.date(from:"2017 12 31")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    

}

extension CalendarVC: JTAppleCalendarViewDelegate {
    
    // Display the cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        cell.dateLabel.text = cellState.text
        configureCell(cell: cell, cellState: cellState)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
        
        
        
    }
}


extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat((value & 0x0000FF)) / 255.0,
            alpha: alpha
            )
    }
}



extension CalendarVC {
    func getThankYou() {

        // Load thankyou from UserDefaults
        let userDefaults = UserDefaults.standard
        if let storedThankYouDataList = userDefaults.object(forKey: "thankYouDataList") as? Data {
            
            if let unarchiveThankYouDataList = NSKeyedUnarchiver.unarchiveObject(
                with: storedThankYouDataList) as? [ThankYouData] {
                thankYouDataSingleton.thankYouDataList.append(contentsOf: unarchiveThankYouDataList)
            }
        }
        if let storedSectionDate = userDefaults.array(forKey: "sectionDate") as? [String] {
            thankYouDataSingleton.sectionDate.append(contentsOf: storedSectionDate)
        }
        
    }
}





