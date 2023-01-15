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

protocol CalendarRouter: Router {
    func presentMyPage()
    func presentEditThankYou(thankYouId: String)
}

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
    var router: CalendarRouter?

    // MARK: - IBOutlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var smallListView: SmallListView!
    @IBOutlet weak var yearMonth: UILabel!

    @IBOutlet weak var listViewTopConstraint: NSLayoutConstraint!

    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator) {
        guard let visibleDates = calendarView?.visibleDates() else { return }
        calendarView?.viewWillTransition(to: .zero,
                                         with: coordinator,
                                         anchorDate: visibleDates.monthDates.first?.date)
    }
}

// MARK: - IBActions
extension CalendarViewController {
    @IBAction func tapUserIcon(_ sender: Any) {
        router?.presentMyPage()
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
private extension CalendarViewController {
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
    
    private func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        yearMonth.text = date.toMonthYearString()
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

    func presentEditThankYouViewController(thankYouId: String) {
        router?.presentEditThankYou(thankYouId: thankYouId)
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

    func showDeleteConfirmationAlert(thankYouId: String) {
        let deleteAction = UIAlertAction(title: R.string.localizable.delete(),
                                         style: .destructive) { [weak self] _ in
            self?.deleteThankYou(thankYouId: thankYouId)
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(),
                                         style: .cancel)
        router?.presentAlert(title: R.string.localizable.deleteThankYou(),
                             message: R.string.localizable.areYouSureYouWantToDeleteThisThankYou(),
                             actions: [deleteAction, cancelAction])
    }

    func deleteThankYou(thankYouId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            showErrorAlert(title: nil, message: R.string.localizable.failedToDelete())
            return
        }
        db.collection(FirestoreConst.usersCollecion)
            .document(userId)
            .collection(FirestoreConst.thankYouListCollection)
            .document(thankYouId)
            .delete(completion: { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    debugPrint(error)
                    self.showErrorAlert(title: nil, message: R.string.localizable.failedToDelete())
                    return
                }
                if let thankYouData = self.thankYouDataSingleton.thankYouDataList.first(where: { $0.id == thankYouId }) {
                    Analytics.logEvent(eventName: AnalyticsEventConst.deleteThankYou,
                                       userId: userId,
                                       targetDate: thankYouData.date)
                }
            })
    }
}

// MARK: - JTAppleCalendarViewDataSource
extension CalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let calendar = Calendar(identifier: .gregorian)

        let formatter = DateFormatter()
        formatter.dateFormat = calendarDateFormat
        formatter.timeZone = calendar.timeZone
        formatter.locale = calendar.locale
        
        let startDate = formatter.date(from: calendarStartDate) ?? Date()
        let endDate = formatter.date(from: calendarEndDate) ?? Date()
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 calendar: calendar)
        return parameters
    }
}

// MARK: - JTAppleCalendarViewDelegate
extension CalendarViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {}
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: R.reuseIdentifier.calendarDayCell.identifier, for: indexPath) as! CalendarDayCell
        let thankYouCount = thankYouDataSingleton.thankYouDataList.filter { $0.date == cellState.date }.count
        cell.bind(cellState: cellState, thankYouCount: thankYouCount)
        cell.bindSelection(isSelected: cellState.isSelected)
        // To make sure draw(_ rect:) gets called when screen is rotated
        cell.setNeedsDisplay()
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if let cell = cell as? CalendarDayCell {
            cell.bindSelection(isSelected: cellState.isSelected)
        }
        getListFromDate(cellState.date)
        appDelegate.selectedDate = cellState.date
        selectedDate = cellState.date.toThankYouDateString()
        let displayDateString = selectedDate
            .toDate(format: R.string.localizable.date_format_thankyou_date())?
            .toYearMonthDayString()
        smallListView.setDateLabel(dateString: displayDateString ?? "")
        smallListView.reloadTableView()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if let cell = cell as? CalendarDayCell {
            cell.bindSelection(isSelected: cellState.isSelected)
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.thankYouCell, for: indexPath)!
        if let thankYouData = selectedList.getSafely(at: indexPath.row) {
            cell.bind(thankYouData: thankYouData)
        }
        cell.delegate = self
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

// MARK: - ThankYouCellDelegate
extension CalendarViewController: ThankYouCellDelegate {
    func thankYouCellDidTapThankYouView(thankYouId: String) {
        let menu = ThankYouCellTapMenu.allCases.map { $0.bottomHalfSheetMenuItem(id: thankYouId) }
        let bottomSheet = BottomHalfSheetMenuViewController.createViewController(
            menu: menu,
            bottomSheetDelegate: self
        )
        present(bottomSheet, animated: true, completion: nil)
    }
}

// MARK: - BottomHalfSheetMenuViewControllerDelegate
extension CalendarViewController: BottomHalfSheetMenuViewControllerDelegate {
    func bottomHalfSheetMenuViewControllerDidTapItem(item: BottomHalfSheetMenuItem) {
        guard let itemRawValue = item.rawValue,
              let cellMenu = ThankYouCellTapMenu(rawValue: itemRawValue),
              let thankYouId = item.id else { return }
        presentedViewController?.dismiss(animated: true, completion: nil)
        switch cellMenu {
        case .edit:
            presentEditThankYouViewController(thankYouId: thankYouId)
        case .delete:
            showDeleteConfirmationAlert(thankYouId: thankYouId)
        }
    }
}
