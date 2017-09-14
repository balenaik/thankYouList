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
    @IBOutlet var tableView: UITableView!
    
    
    
    // Get the singleton
    let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
    
    // Set colors
    let navigationBarBgColor = UIColor(colorWithHexValue: 0xfff8e8)
    let navigationBarTextColor = UIColor(colorWithHexValue: 0xfe939d)
    let sectionBgColor = UIColor(colorWithHexValue: 0xfcb5b5)
    let grayColor = UIColor(colorWithHexValue: 0x5a5a5a)
    let highGrayColor = UIColor(colorWithHexValue: 0xc8c8c8)
    let brownColor = UIColor(colorWithHexValue: 0x81726a)
    let pinkColor = UIColor(colorWithHexValue: 0xfcb5b5)
    
    var delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var sectionItems = [ThankYouData]()
    var selectedDate: String!
    
    @IBAction func backToList(_ sender: Any) {
        // Return
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addButton(_ sender: Any) {
        // 入力画面に遷移
        let storyboard: UIStoryboard = self.storyboard!
        // Set selected date and pass it to the addThankYouDataVC
        self.delegate.selectedDate = selectedDate
        let addThankYouDataVC = storyboard.instantiateViewController(withIdentifier: "addThankYouDataVC") as! ThankYouList.AddThankYouDataVC
        let navi = UINavigationController(rootViewController: addThankYouDataVC)
        self.present(navi, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup the background color for navigationbar
        self.navigationController?.navigationBar.barTintColor = navigationBarBgColor
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // setup the text color for navagationbar
        self.navigationController?.navigationBar.tintColor = navigationBarTextColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : navigationBarTextColor]

        // Set the opening month when the screen is showed
        calendarView.scrollToDate(Date(), animateScroll: false)
        
        setupCalendarView()
        
        DispatchQueue.main.async {
            self.calendarView.reloadData()
        }
        
        // Set the opening date on calendar when the screen is showed the first time
        calendarView.selectDates([Date()])
        
        
        /* tableView below */
        
        // change the height of cells depending on the text
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set the opening date of tableView when the screen is showed first time
        getSectionItems(date: Date())
        self.formatter.dateFormat = "yyyy/MM/dd"
        selectedDate = self.formatter.string(from: Date())
        
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
        
        validCell.oneDotView.isHidden = true
        validCell.twoDotsView.isHidden = true
        validCell.threeDotsView.isHidden = true
        validCell.dotsAndPlusView.isHidden = true
        
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
    
    /* functions for tableView below */
    // the function for getting section items
    func getSectionItems(date: Date) {
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        // Array for thankYou
        let thankYouDataList: [ThankYouData] = thankYouDataSingleton.thankYouDataList
        // Set sectionItems
        self.formatter.dateFormat = "yyyy/MM/dd"
        sectionItems = thankYouDataList.filter({$0.thankYouDate == self.formatter.string(from: date)})
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
        
        let startDate = formatter.date(from:"2015 01 01")!
        let endDate = formatter.date(from:"2025 12 31")!
        
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
        getSectionItems(date: cellState.date)
        self.formatter.dateFormat = "yyyy/MM/dd"
        selectedDate = self.formatter.string(from: cellState.date)
        self.tableView.reloadData()
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



extension CalendarVC: UITableViewDataSource, UITableViewDelegate {
    
    // returns the number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionItems.count
    }

    // return a cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Storyboardで指定したthankyouCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "thankYouCalendarCell", for: indexPath)
        // Put the thankYou value if there is something in sectionDate
        if !sectionItems.isEmpty {
            // 行番号にあったThankYouのタイトルを取得 & get the item for the row in this section
            let myThankYouData = sectionItems[indexPath.row]
            // セルのラベルにthankYouのタイトルをセット
            cell.textLabel?.text = myThankYouData.thankYouValue
            // change the text size
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        }
        return cell
    }
    
    // returns the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // returns the title of sections
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectedDate
    }
    
    // change the detail of section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        // 余白を作る(UIViewをセクションのビューに指定（だからxとかy指定しても意味ない）
        let view = UIView(frame: CGRect(x:0, y:0, width:20, height:20))
        view.backgroundColor = sectionBgColor
        let label :UILabel = UILabel(frame: CGRect(x: 15, y: 6.0, width: tableView.frame.width, height: 20))
        label.textColor = UIColor.white
        label.text = selectedDate
        //指定したlabelをセクションビューのサブビューに指定
        view.addSubview(label)
        return view
    }
    
    // reload again
    override func viewWillAppear(_ animated: Bool) {
        getSectionItems(date: formatter.date(from: selectedDate)!)
        self.tableView.reloadData()
        self.calendarView.reloadData()
    }
    
    
    // when a cell is tapped it goes the edit screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Look for the index number in sectionDate and set it to delegate
        self.delegate.indexPathSection = thankYouDataSingleton.sectionDate.index(of: selectedDate)!
        // Input the indexPath.row in AppDelegate
        self.delegate.indexPathRow = indexPath.row
        // going to the edit page
        let storyboard: UIStoryboard = self.storyboard!
        let editThankYouDataVC = storyboard.instantiateViewController(withIdentifier: "editThankYouDataVC") as! ThankYouList.EditThankYouDataVC
        let navi = UINavigationController(rootViewController: editThankYouDataVC)
        self.present(navi, animated: true, completion: nil)
    }
    
}


