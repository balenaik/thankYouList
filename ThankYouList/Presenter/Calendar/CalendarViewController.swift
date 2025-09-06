//
//  CalendarViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2017/09/04.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Combine
import CombineCocoa
import FloatingPanel

class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    private let thankYouDataSingleton = DefaultInMemoryDataStore.shared
    private var selectedList = [ThankYouData]()
    private var estimatedRowHeights = [String : CGFloat]()
    private var selectedDate = ""
    private var listViewOriginalTopConstant = CGFloat(0)
    private var listViewMostTopConstant = CGFloat(0)
    private var isDraggingListView = false
    private let analyticsManager = DefaultAnalyticsManager()
    private var cancellables = Set<AnyCancellable>()

    var viewModel: CalendarViewModel!

    // MARK: - IBOutlets
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var calendarView: JTAppleCalendarView!
    @IBOutlet private weak var smallListView: SmallListView!
    @IBOutlet private weak var yearMonthLabel: UILabel!
    @IBOutlet private weak var userIcon: UIBarButtonItem!

    @IBOutlet private weak var listViewTopConstraint: NSLayoutConstraint!

    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        bind()
        viewModel.inputs.viewDidLoad.send()
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

        setupCalendarView()

        smallListView.setupTableView(self)
        smallListView.delegate = self

        getListFromDate(Date())

        listViewMostTopConstant = -stackView.frame.height
    }

    private func setupCalendarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0

        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.selectDates([Date()])
    }

    private func bind() {
        bindOutputs()
        bindInputs()
    }

    private func bindOutputs() {
        viewModel.outputs
            .reconfigureCalendarDataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.calendarView.calendarDataSource = self
                self.calendarView.reloadData(withanchor: $0)
            }
            .store(in: &cancellables)

        viewModel.outputs
            .reloadCurrentVisibleCalendar
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                let visibleCalendarIndex = 12
                self?.calendarView.reloadSections(IndexSet(integer: visibleCalendarIndex))
            }
            .store(in: &cancellables)

        viewModel.outputs
            .updateYearMonthLabel
            .assign(to: \.text, on: yearMonthLabel)
            .store(in: &cancellables)

        viewModel.outputs
            .dismissPresentedView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.presentedViewController?.dismiss(animated: true, completion: nil)
            }
            .store(in: &cancellables)
    }

    private func bindInputs() {
        userIcon.tapPublisher
            .subscribe(viewModel.inputs.userIconDidTap)
            .store(in: &cancellables)
    }

    private func getListFromDate(_ date: Date) {
        let thankYouDataList = thankYouDataSingleton.thankYouList
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
        viewModel.outputs.calendarConfiguration.value?.toConfigurationParameters ??
        ConfigurationParameters(startDate: Date(), endDate: Date())
    }
}

// MARK: - JTAppleCalendarViewDelegate
extension CalendarViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {}
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: R.reuseIdentifier.calendarDayCell.identifier, for: indexPath) as! CalendarDayCell
        let thankYouCount = thankYouDataSingleton.thankYouList.filter { $0.date == cellState.date }.count
        cell.bind(cellState: cellState,
                  thankYouCount: thankYouCount,
                  isSelected: viewModel.outputs.currentSelectedDate.value.isSameDayAs(date))
        // To make sure draw(_ rect:) gets called when screen is rotated
        cell.setNeedsDisplay()
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        viewModel.inputs.calendarDidSelectDate.send(date)
        // TODO: Will migrate to VM later
        getListFromDate(cellState.date)
        selectedDate = cellState.date.toThankYouDateString()
        let displayDateString = selectedDate
            .toDate(format: R.string.localizable.date_format_thankyou_date())?
            .toYearMonthDayString()
        smallListView.setDateLabel(dateString: displayDateString ?? "")
        smallListView.reloadTableView()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let firstVisibleDate = visibleDates.monthDates.first?.date else { return }
        viewModel.inputs.calendarDidScrollToMonth.send(firstVisibleDate)
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {}
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
        guard let selectedDate = calendarView.selectedDates.getSafely(at: 0) else { return }
        analyticsManager.logEvent(
            eventName: AnalyticsEventConst.calendarSmallListViewFullScreen,
            targetDate: selectedDate)
    }
}

// MARK: - ThankYouCellDelegate
extension CalendarViewController: ThankYouCellDelegate {
    func thankYouCellDidTapThankYouView(thankYouId: String) {
        let menu = ThankYouCellTapMenu.allCases.map { $0.bottomHalfSheetMenuItem(id: thankYouId) }
        let floatingPanelViewController = FloatingPanelController.createBottomHalfSheetMenu(menu: menu)
        guard let bottomHalfSheetMenuViewController = floatingPanelViewController.contentBottomHalfSheetMenuViewController else {
            return
        }
        bottomHalfSheetMenuViewController.itemDidTap
            .subscribe(viewModel.inputs.bottomHalfSheetMenuDidTap)
            .store(in: &bottomHalfSheetMenuViewController.cancellables)

        present(floatingPanelViewController, animated: true, completion: nil)
    }
}
