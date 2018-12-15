//
//  CalendarVC.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2017/09/04.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit
import JTAppleCalendar
import FirebaseFirestore
import FirebaseAuth

class CalendarVC: UIViewController {
    
    // MARK: - Properties
    private let formatter = DateFormatter()
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var sectionItems = [ThankYouData]()
    private var selectedDate: String = ""
    private let db = Firestore.firestore()
    private let thankYouDataSingleton = GlobalThankYouData.sharedInstance
    private let todaysDate = Date()
    
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearMonth: UILabel!
    @IBOutlet weak var selectedDateView: UIView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    

    // MARK: - IBActions
    @IBAction func tappedMenuButton(_ sender: Any) {
        slideMenuController()?.openLeft()
    }
    
    
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        selectedDateLabel = UILabel(frame: CGRect.zero)
        super.init(coder: aDecoder)
    }
    
    
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.formatter.dateFormat = "yyyy/MM/dd"
        selectedDate = self.formatter.string(from: Date())
        selectedDateLabel.text = selectedDate

        self.navigationController?.navigationBar.barTintColor = TYLColor.navigationBarBgColor
        self.navigationController?.navigationBar.tintColor = TYLColor.navigationBarTextColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : TYLColor.navigationBarTextColor]
        
        calendarView.scrollToDate(Date(), animateScroll: false)
        setupCalendarView()
        calendarView.selectDates([Date()])
        checkForUpdates()
        
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension

        getSectionItems(date: Date())
        slideMenuController()?.addPriorityToMenuGesuture(calendarView)
        
        DispatchQueue.main.async {
            self.calendarView.reloadData()
        }
    }


    
    // MARK: - Private Methods
    private func setupCalendarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    
    private func configureCell(cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCell else { return }
        
        handleCellSelected(view: validCell, cellState: cellState)
        handleCellTextColor(view: validCell, cellState: cellState)
        handleCellEvents(view: validCell, cellState: cellState)
    }
    
    private func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCell else { return }
        
        if cellState.isSelected {
            validCell.dateLabel.textColor = TYLColor.TYLGrayColor
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = TYLColor.TYLGrayColor
            } else {
                validCell.dateLabel.textColor = TYLColor.highGrayColor
            }
        }

        formatter.dateFormat = "yyyy MM dd"
        
        let todaysDateString = formatter.string(from: todaysDate)
        let monthDateString = formatter.string(from: cellState.date)
        
        if todaysDateString == monthDateString {
            validCell.dateLabel.textColor = TYLColor.pinkColor
        }
    }
    
    private func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCell else { return }
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
    }
    
    private func handleCellEvents(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCell else { return }
        
        validCell.oneDotView.isHidden = true
        validCell.twoDotsView.isHidden = true
        validCell.threeDotsView.isHidden = true
        validCell.dotsAndPlusView.isHidden = true
        
        formatter.dateFormat = "yyyy/MM/dd"
        if thankYouDataSingleton.thankYouDataList.filter({$0.date == formatter.string(from: cellState.date)}).count == 1 {
            validCell.oneDotView.isHidden = false
        } else if thankYouDataSingleton.thankYouDataList.filter({$0.date == formatter.string(from: cellState.date)}).count == 2 {
            validCell.twoDotsView.isHidden = false
        } else if thankYouDataSingleton.thankYouDataList.filter({$0.date == formatter.string(from: cellState.date)}).count == 3 {
            validCell.threeDotsView.isHidden = false            
        } else if thankYouDataSingleton.thankYouDataList.filter({$0.date == formatter.string(from: cellState.date)}).count >= 4 {
            validCell.dotsAndPlusView.isHidden = false
        }
    }
    
    private func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        let monthYearDF = DateFormatter()
        monthYearDF.dateFormat = String(format: NSLocalizedString("monthYear", comment: ""), "MMMM", "yyyy")
        self.yearMonth.text = monthYearDF.string(from: date)
    }
    
    private func getSectionItems(date: Date) {
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        let thankYouDataList: [ThankYouData] = thankYouDataSingleton.thankYouDataList
        self.formatter.dateFormat = "yyyy/MM/dd"
        sectionItems = thankYouDataList.filter({$0.date == self.formatter.string(from: date)})
    }
    
    private func checkForUpdates() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Not login? error")
            return
        }
        let uid16string = String(uid.prefix(16))
        db.collection("users").document(uid).collection("thankYouList").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let weakSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let snapShot = querySnapshot else { return }
            for diff in snapShot.documentChanges {
                if diff.type == .added {
                    let thankYouData = ThankYouData(dictionary: diff.document.data())
                    guard var newThankYouData = thankYouData else { break }
                    let decryptedValue = Crypto().decryptString(encryptText: newThankYouData.encryptedValue, key: uid16string)
                    newThankYouData.id = diff.document.documentID
                    newThankYouData.value = decryptedValue
                    let thankYouDataIds: [String] = weakSelf.thankYouDataSingleton.thankYouDataList.map{$0.id}
                    if !thankYouDataIds.contains(newThankYouData.id) {
                        weakSelf.thankYouDataSingleton.thankYouDataList.append(newThankYouData)
                    }
                    if !weakSelf.thankYouDataSingleton.sectionDate.contains(newThankYouData.date) {
                        weakSelf.thankYouDataSingleton.sectionDate.append(newThankYouData.date)
                    }
                    weakSelf.thankYouDataSingleton.sectionDate.sort(by:>)
                }
                if diff.type == .removed {
                    let removedDataId = diff.document.documentID
                    for (index, thankYouData) in weakSelf.thankYouDataSingleton.thankYouDataList.enumerated() {
                        if thankYouData.id == removedDataId {
                            weakSelf.thankYouDataSingleton.thankYouDataList.remove(at: index)
                            weakSelf.deleteSectionDateIfNeeded(sectionDate: thankYouData.date)
                            break
                        }
                    }
                }
                if diff.type == .modified {
                    let thankYouData = ThankYouData(dictionary: diff.document.data())
                    guard var editedThankYouData = thankYouData else { break }
                    let decryptedValue = Crypto().decryptString(encryptText: editedThankYouData.encryptedValue, key: uid16string)
                    editedThankYouData.id = diff.document.documentID
                    editedThankYouData.value = decryptedValue
                    for (index, thankYouData) in weakSelf.thankYouDataSingleton.thankYouDataList.enumerated() {
                        if editedThankYouData.id == thankYouData.id {
                            weakSelf.thankYouDataSingleton.thankYouDataList.remove(at: index)
                            weakSelf.deleteSectionDateIfNeeded(sectionDate: thankYouData.date)
                            break
                        }
                    }
                    weakSelf.thankYouDataSingleton.thankYouDataList.append(editedThankYouData)
                    if !weakSelf.thankYouDataSingleton.sectionDate.contains(editedThankYouData.date) {
                        weakSelf.thankYouDataSingleton.sectionDate.append(editedThankYouData.date)
                        weakSelf.thankYouDataSingleton.sectionDate.sort(by:>)
                    }
                }
            }
            DispatchQueue.main.async {
                if let date = weakSelf.formatter.date(from: weakSelf.selectedDate) {
                    weakSelf.getSectionItems(date: date)
                }
                weakSelf.calendarView.reloadData()
                weakSelf.tableView.reloadData()
            }
        }
    }
    
    private func deleteSectionDateIfNeeded(sectionDate: String) {
        let sectionItemsCount = thankYouDataSingleton.thankYouDataList.filter({$0.date == sectionDate}).count
        if sectionItemsCount == 0 {
            thankYouDataSingleton.sectionDate = thankYouDataSingleton.sectionDate.filter({$0 != sectionDate})
            thankYouDataSingleton.sectionDate.sort(by:>)
        }
    }
    
    
    // MARK: - Overrides
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



// MARK: - Extensions
extension CalendarVC: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from:"2016 01 01")!
        let endDate = formatter.date(from:"2020 12 31")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
}

extension CalendarVC: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        //
    }
    
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
        selectedDateLabel.text = selectedDate
        appDelegate.selectedDate = selectedDate
        self.tableView.reloadData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}


extension CalendarVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let date = formatter.date(from: selectedDate) {
            getSectionItems(date: date)
        }
        return self.sectionItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "thankYouCalendarCell", for: indexPath)
        if !sectionItems.isEmpty {
            let myThankYouData = sectionItems[indexPath.row]
            cell.textLabel?.text = myThankYouData.value
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.textLabel?.textColor = TYLColor.textColor
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectedDate
    }
    
    func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editingThankYouData = sectionItems[indexPath.row]
        let vc = EditThankYouDataVC.createViewController(thankYouData: editingThankYouData)
        let navi = UINavigationController(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
}


