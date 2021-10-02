//
//  CalendarViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2017/09/04.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit
import JTAppleCalendar
import FirebaseFirestore
import FirebaseAuth
import Firebase

private let calendarDateFormat = "yyyy/MM/dd"
private let calendarStartDate = "2016/01/01"
private let calendarEndDate = "2025/12/31"

class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let thankYouDataSingleton = GlobalThankYouData.sharedInstance
    private var selectedList = [ThankYouData]()
    private var estimatedRowHeights = [String : CGFloat]()
    private var selectedDate = ""
    private var listViewOriginalTopConstant = CGFloat(0)
    private var listViewMostTopConstant = CGFloat(0)
    private var isDraggingListView = false
    private let db = Firestore.firestore()
    
    
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var smallListView: SmallListView!
    @IBOutlet weak var yearMonth: UILabel!

    @IBOutlet weak var listViewTopConstraint: NSLayoutConstraint!
   
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - IBActions
extension CalendarViewController {
    @IBAction func tapUserIcon(_ sender: Any) {
        guard let myPageViewController = MyPageViewController.createViewController() else { return }
        present(myPageViewController, animated: true, completion: nil)
    }
    
    @IBAction func draggedListView(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            beginDraggingListView()
        case .changed:
            whileDraggingListView(translationPointY: sender.translation(in: self.view).y)
        case .ended:
            endDraggingListView(velocityY: sender.velocity(in: self.view).y)
        default:
            break
        }
    }
}

// MARK: - Private Methods
extension CalendarViewController {
    func setupView() {
        navigationItem.title = R.string.localizable.calendar_navigationbar_title()
        tabBarItem.title = R.string.localizable.calendar_tabbar_title()

        NotificationCenter.default.addObserver(self, selector: #selector(CalendarViewController.updatedThankYouList(notification:)), name: Notification.Name(rawValue: NotificationConst.THANK_YOU_LIST_UPDATED), object: nil)

        calendarView.scrollToDate(Date(), animateScroll: false)
        setupCalendarView()
        calendarView.selectDates([Date()])

        smallListView.setupTableView(self)
        smallListView.delegate = self

        getListFromDate(Date())

        listViewMostTopConstant = -stackView.frame.height
    }

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
                validCell.dateLabel.textColor = UIColor.highGray
            }
        }

        let todaysDateString = Date().toThankYouDateString()
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
    
    private func getListFromDate(_ date: Date) {
        let thankYouDataList = thankYouDataSingleton.thankYouDataList
        estimatedRowHeights.removeAll()
        selectedList = thankYouDataList.filter({$0.date == date})
    }
    
    private func updateCurrentSectionItems() {
        guard let selectedDate = calendarView.selectedDates.getSafely(at: 0) else { return }
        getListFromDate(selectedDate)
    }
    
    @objc func updatedThankYouList(notification: Notification) {
        updateCurrentSectionItems()
        DispatchQueue.main.async {
            self.calendarView.reloadData()
            self.smallListView.reloadTableView()
        }
    }
    
    private func beginDraggingListView() {
        isDraggingListView = true
        listViewOriginalTopConstant = listViewTopConstraint.constant
    }
    
    private func whileDraggingListView(translationPointY: CGFloat) {
        if !isDraggingListView { return }
        /// if the listView is on the top of the contentView
        if listViewTopConstraint.constant < listViewMostTopConstant {
            smallListView.isFullScreen = true
            return
        }
        /// if the listView is at the bottom of the calendar
        if listViewTopConstraint.constant > 1 {
            smallListView.isFullScreen = false
            return
        }
        let translatedConstraint = (listViewOriginalTopConstant + translationPointY) < listViewMostTopConstant ? listViewMostTopConstant : (listViewOriginalTopConstant + translationPointY)
        listViewTopConstraint.constant =  translatedConstraint
        smallListView.isFullScreen = translatedConstraint == listViewMostTopConstant ? true : false
        self.view.layoutIfNeeded()
    }

    private func endDraggingListView(velocityY: CGFloat) {
        isDraggingListView = false
        if listViewTopConstraint.constant == 0 || listViewTopConstraint.constant == listViewMostTopConstant {
            smallListView.isFullScreen = listViewTopConstraint.constant == listViewMostTopConstant ? true : false
            return
         }
        var destination = CGFloat(0)
        if ((velocityY <= 10 && velocityY >= -10)
            && listViewTopConstraint.constant < -stackView.frame.height / 2)
            || velocityY < -10 {
            destination = -stackView.frame.height
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.listViewTopConstraint.constant = destination
            self.view.layoutIfNeeded()
            if destination != self.listViewMostTopConstant {
                self.smallListView.setTableViewOffsetZero()
            }
        }, completion: nil)
        /// Adjust corner radius on selectedDateView depending on destination
        if destination == listViewMostTopConstant {
            smallListView.isFullScreen = true
        } else {
            smallListView.isFullScreen = false
            smallListView.setTableViewScrollingSetting(isEnabled: false)
        }
    }
}



// MARK: - JTAppleCalendarViewDataSource
extension CalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = calendarDateFormat
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: calendarStartDate) ?? Date()
        let endDate = formatter.date(from: calendarEndDate) ?? Date()
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
}

// MARK: - JTAppleCalendarViewDelegate
extension CalendarViewController: JTAppleCalendarViewDelegate {
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
        getListFromDate(cellState.date)
        appDelegate.selectedDate = cellState.date
        selectedDate = cellState.date.toThankYouDateString()
        let displayDateString = selectedDate.toThankYouDate()?.toYearMonthDayString()
        smallListView.setDateLabel(dateString: displayDateString ?? "")
        smallListView.reloadTableView()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ThankYouCell.cellIdentifier(), for: indexPath) as! ThankYouCell
        if let thankYouData = selectedList.getSafely(at: indexPath.row) {
            cell.bind(thankYouData: thankYouData)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Somehow when return 0 with grouped tableview, it creates extra space on header...
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let thankYouId =  selectedList.getSafely(at: indexPath.row)?.id,
           let height = estimatedRowHeights[thankYouId] {
            return height
        }
        return tableView.estimatedRowHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.updateConstraints()
        if let thankYouId =  selectedList.getSafely(at: indexPath.row)?.id {
            estimatedRowHeights[thankYouId] = cell.frame.size.height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let editingThankYouData = selectedList.getSafely(at: indexPath.row) else { return }
        let vc = EditThankYouViewController.createViewController(thankYouData: editingThankYouData)
        let navi = UINavigationController(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if smallListView.isFullScreen
            && scrollView.contentOffset.y <= 0
            && scrollView.panGestureRecognizer.velocity(in: self.view).y > 0 {
            beginDraggingListView()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isDraggingListView
            && smallListView.isFullScreen
            && scrollView.contentOffset.y <= 0
            && scrollView.panGestureRecognizer.velocity(in: self.view).y > 0 {
            beginDraggingListView()
        }
        if isDraggingListView {
            if smallListView.isFullScreen
                && scrollView.panGestureRecognizer.velocity(in: self.view).y < 0 {
            } else {
                scrollView.contentOffset.y = 0
                scrollView.showsVerticalScrollIndicator = false
                whileDraggingListView(translationPointY: scrollView.panGestureRecognizer.translation(in: self.view).y)
                return
            }
        }
        isDraggingListView = false
        smallListView.setTableViewScrollingSetting(isEnabled: true)
        scrollView.showsVerticalScrollIndicator = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isDraggingListView {
            endDraggingListView(velocityY: scrollView.panGestureRecognizer.velocity(in: self.view).y)
        }
    }
}

// MARK: - SmallListViewDelegate
extension CalendarViewController: SmallListViewDelegate {
    func smallListViewBecomeFullScreen(_ view: SmallListView) {
        guard let user = Auth.auth().currentUser,
            let selectedDate = calendarView.selectedDates.getSafely(at: 0) else { return }
        Analytics.logEvent(eventName: AnalyticsEventConst.calendarSmallListViewFullScreen, userId: user.uid, targetDate: selectedDate)
    }
}

// MARK: - Public
extension CalendarViewController {
    static func createViewController() -> UIViewController? {
        guard let viewController = R.storyboard.thankYouCalendar().instantiateInitialViewController() else { return nil }
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
