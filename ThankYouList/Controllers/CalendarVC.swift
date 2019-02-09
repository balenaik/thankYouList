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
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let thankYouDataSingleton = GlobalThankYouData.sharedInstance
    private var sectionItems = [ThankYouData]()
    private var selectedDate = ""
    private var listViewOriginalTopConstant = CGFloat(0)
    private var listViewMostTopConstant = CGFloat(0)
    private let db = Firestore.firestore()
    private let todaysDate = Date()
    
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var yearMonth: UILabel!
    @IBOutlet weak var selectedDateView: UIView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    @IBOutlet weak var listViewTopConstraint: NSLayoutConstraint! {
        didSet {
            if selectedDateView != nil {
                if listViewTopConstraint.constant <= listViewMostTopConstant {
                    selectedDateView.layer.cornerRadius = 0
                } else {
                    selectedDateView.layer.cornerRadius = 10
                }
            }
        }
    }
    

    // MARK: - IBActions
    @IBAction func tappedMenuButton(_ sender: Any) {
        slideMenuController()?.openLeft()
    }
    

    @IBAction func draggedListView(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            listViewOriginalTopConstant = listViewTopConstraint.constant
        case .changed:
            /// if the listView is on the top of the contentView
            if listViewTopConstraint.constant < -stackView.frame.height
                || listViewTopConstraint.constant >= listViewMostTopConstant {
                selectedDateView.layer.cornerRadius = 0
                break
            }
            /// if the listView is at the bottom of the calendar
            if listViewTopConstraint.constant > 1 {
                break
            }
            listViewTopConstraint.constant =  listViewOriginalTopConstant + sender.translation(in: self.view).y
            selectedDateView.layer.cornerRadius = 10
            self.view.layoutIfNeeded()
        case .ended:
            if listViewTopConstraint.constant == 0 || listViewTopConstraint.constant == -stackView.frame.height {
                break
            }
            let velocity = sender.velocity(in: self.view).y
            var destination = CGFloat(0)
            if ((velocity <= 10 && velocity >= -10)
                && listViewTopConstraint.constant < -stackView.frame.height / 2)
                || velocity < -10 {
                destination = -stackView.frame.height
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.listViewTopConstraint.constant = destination
                self.view.layoutIfNeeded()
                }, completion: nil)
            /// Adjust corner radius on selectedDateView depending on destination
            if destination == -stackView.frame.height {
                selectedDateView.layer.cornerRadius = 0
            } else {
                selectedDateView.layer.cornerRadius = 10
            }
        default:
            break
        }
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
        
        selectedDate = Date().toThankYouDateString()
        selectedDateLabel.text = selectedDate
        selectedDateView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        selectedDateView.dropShadow()

        self.navigationController?.navigationBar.barTintColor = TYLColor.navigationBarBgColor
        self.navigationController?.navigationBar.tintColor = TYLColor.navigationBarTextColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : TYLColor.navigationBarTextColor]
        
        NotificationCenter.default.addObserver(self, selector: #selector(CalendarVC.updatedThankYouList(notification:)), name: Notification.Name(rawValue: NotificationConst.THANK_YOU_LIST_UPDATED), object: nil)
        
        calendarView.scrollToDate(Date(), animateScroll: false)
        setupCalendarView()
        calendarView.selectDates([Date()])
        
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension

        getSectionItems(date: Date())
        slideMenuController()?.addPriorityToMenuGesuture(calendarView)
        
        listViewMostTopConstant = contentView.frame.height - stackView.frame.height - (navigationController?.navigationBar.frame.size.height)! - UIApplication.shared.statusBarFrame.size.height - tabBarController!.tabBar.frame.size.height
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

        let todaysDateString = todaysDate.toThankYouDateString()
        let monthDateString = cellState.date.toThankYouDateString()
        
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
        
        let count = thankYouDataSingleton.thankYouDataList.filter({$0.date == cellState.date}).count
        switch count {
        case 0:
            break
        case 1:
            validCell.oneDotView.isHidden = false
        case 2:
            validCell.twoDotsView.isHidden = false
        case 3:
            validCell.threeDotsView.isHidden = false
        default:
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
        let thankYouDataList = thankYouDataSingleton.thankYouDataList
        sectionItems = thankYouDataList.filter({$0.date == date})
    }
    
    private func updateCurrentSectionItems() {
        let selectedDate = calendarView.selectedDates[0]
        getSectionItems(date: selectedDate)
    }
    
    @objc func updatedThankYouList(notification: Notification) {
        updateCurrentSectionItems()
        DispatchQueue.main.async {
            self.calendarView.reloadData()
            self.tableView.reloadData()
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
        let formatter = DateFormatter()
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
        appDelegate.selectedDate = cellState.date
        
        selectedDate = cellState.date.toThankYouDateString()
        selectedDateLabel.text = selectedDate
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
        if let date = selectedDate.toThankYouDate() {
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
        let vc = EditThankYouViewController.createViewController(thankYouData: editingThankYouData)
        let navi = UINavigationController(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


