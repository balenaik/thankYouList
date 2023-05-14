//
//  ThankYouListViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 4/11/17.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase
import SkeletonView
import FloatingPanel

private let skeletonedThankYouCellCount = 3

protocol ThankYouListRouter: Router {
    func presentMyPage()
    func presentEditThankYou(thankYouId: String)
}

class ThankYouListViewController: UIViewController {

    struct Section {
        /// yyyy/MM (String)
        var sectionDateString: String
        var displayDateString: String
        var thankYouList: [ThankYouData]
    }

    private var db = Firestore.firestore()
    private let analyticsManager = DefaultAnalyticsManager()
    private var thankYouDataSingleton = GlobalThankYouData.sharedInstance
    private var sections = [Section]()
    private var estimatedRowHeights = [String : CGFloat]()
    private var hasLoadedThankYouList = false

    var router: ThankYouListRouter?

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var scrollIndicator: ListScrollIndicator!
    @IBOutlet private weak var emptyView: EmptyView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
}

// MARK: - IBActions
extension ThankYouListViewController {
    @IBAction func tapUserIcon(_ sender: Any) {
        router?.presentMyPage()
    }
}

// MARK: - Private Methods
private extension ThankYouListViewController {
    func setupView() {
        navigationItem.title = R.string.localizable.list_navigationbar_title()
        tabBarItem.title = R.string.localizable.calendar_tabbar_title()

        thankYouDataSingleton.thankYouDataList = []
        sections = []
        loadAndCheckForUpdates()

        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(R.nib.thankYouCell)
        tableView?.register(UINib(nibName: ListSectionHeaderView.cellIdentifier(),
                                  bundle: nil),
                            forHeaderFooterViewReuseIdentifier: ListSectionHeaderView.cellIdentifier())

        emptyView.isHidden = true
        scrollIndicator.setup(scrollView: tableView)
        scrollIndicator.delegate = self
    }

    private func loadAndCheckForUpdates() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Not login? error")
            return
        }
       let uid16string = String(uid.prefix(16))
        db.collection("users").document(uid).collection("thankYouList").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                self.hasLoadedThankYouList = true
                return
            }
            guard let snapShot = querySnapshot else {
                self.hasLoadedThankYouList = true
                return
            }
            for diff in snapShot.documentChanges {
                if diff.type == .added {
                    let thankYouData = ThankYouData(dictionary: diff.document.data())
                    guard var newThankYouData = thankYouData else { break }
                    let decryptedValue = Crypto().decryptString(encryptText: newThankYouData.encryptedValue, key: uid16string)
                    newThankYouData.id = diff.document.documentID
                    newThankYouData.value = decryptedValue
                    let thankYouDataIds: [String] = self.thankYouDataSingleton.thankYouDataList.map{$0.id}
                    if !thankYouDataIds.contains(newThankYouData.id) {
                        self.thankYouDataSingleton.thankYouDataList.append(newThankYouData)
                        self.addThankYouDataToSection(thankYouData: newThankYouData)
                    }
                }
                if diff.type == .removed {
                    let removedDataId = diff.document.documentID
                    for (index, thankYouData) in self.thankYouDataSingleton.thankYouDataList.enumerated() {
                        if thankYouData.id == removedDataId {
                            self.thankYouDataSingleton.thankYouDataList.remove(at: index)
                            self.deleteThankYouDataFromSection(thankYouData: thankYouData)
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
                    for (index, thankYouData) in self.thankYouDataSingleton.thankYouDataList.enumerated() {
                        if editedThankYouData.id == thankYouData.id {
                            self.thankYouDataSingleton.thankYouDataList.remove(at: index)
                            self.deleteThankYouDataFromSection(thankYouData: thankYouData)
                            break
                        }
                    }
                    self.thankYouDataSingleton.thankYouDataList.append(editedThankYouData)
                    self.addThankYouDataToSection(thankYouData: editedThankYouData)
                }
            }
            DispatchQueue.main.async {
                if self.thankYouDataSingleton.thankYouDataList.count == 0 {
                    self.emptyView.isHidden = false
                } else {
                    self.emptyView.isHidden = true
                }
                self.hasLoadedThankYouList = true
                self.postNotificationThankYouListUpdated()
                self.tableView.reloadData()
                self.scrollIndicator.updatedContent()
            }
        }
    }
    
    private func postNotificationThankYouListUpdated() {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NotificationConst.THANK_YOU_LIST_UPDATED), object: nil, userInfo: nil))
    }
    
    private func addThankYouDataToSection(thankYouData: ThankYouData) {
        /// Crop only year and month (yyyy/MM) from thank you date
        let dateYearMonthString = String(thankYouData.date.toThankYouDateString().prefix(7))
        let sectionIndex = sections.firstIndex(where: { $0.sectionDateString == dateYearMonthString })
        if let index = sectionIndex {
            sections[index].thankYouList.append(thankYouData)
            sections[index].thankYouList.sort(by: {$0.date > $1.date})
        } else {
            guard let dateYearMonth = dateYearMonthString.toDate(
                format: R.string.localizable.date_format_year_month()) else { return }
            let newSection = Section(sectionDateString: dateYearMonthString,
                                     displayDateString: dateYearMonth.toYearMonthString(),
                                     thankYouList: [thankYouData])
            sections.append(newSection)
            sections.sort(by: {$0.sectionDateString > $1.sectionDateString})
        }
    }
    
    private func deleteThankYouDataFromSection(thankYouData: ThankYouData) {
        /// Crop only year and month (yyyy/MM) from thank you date
        let dateYearMonthString = String(thankYouData.date.toThankYouDateString().prefix(7))
        guard let sectionIndex = sections.firstIndex(where: {$0.sectionDateString == dateYearMonthString}),
            let thankYouIndex = sections[sectionIndex].thankYouList
                .firstIndex(where: {$0.id == thankYouData.id}) else { return }
        sections[sectionIndex].thankYouList.remove(at: thankYouIndex)
        if sections[sectionIndex].thankYouList.count == 0 {
            sections.remove(at: sectionIndex)
        }
    }

    func presentEditThankYouViewController(thankYouId: String) {
        router?.presentEditThankYou(thankYouId: thankYouId)
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
                    self.analyticsManager.logEvent(
                        eventName: AnalyticsEventConst.deleteThankYou,
                        userId: userId,
                        targetDate: thankYouData.date)
                }
            })
    }
}
    
    
// MARK: - UITableViewDataSource
extension ThankYouListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard hasLoadedThankYouList else {
            return skeletonedThankYouCellCount
        }
        return sections.getSafely(at: section)?.thankYouList.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.thankYouCell, for: indexPath)!
        guard hasLoadedThankYouList else {
            cell.showLoadingSkeleton()
            return cell
        }
        if let section = sections.getSafely(at: indexPath.section),
           let thankYouData = section.thankYouList.getSafely(at: indexPath.row) {
            scrollIndicator.bind(title: section.displayDateString)
            cell.bind(thankYouData: thankYouData)
        }
        cell.delegate = self
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return hasLoadedThankYouList ? sections.count : 1
    }
}

// MARK: - UITableViewDelegate
extension ThankYouListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ListSectionHeaderView.cellIdentifier()) as! ListSectionHeaderView
        guard hasLoadedThankYouList else {
            header.showLoadingSkeleton()
            return header
        }
        if let sct = sections.getSafely(at: section) {
            header.bind(sectionString: sct.displayDateString)
        }
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ListSectionHeaderView.cellHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard hasLoadedThankYouList else {
            return tableView.estimatedRowHeight
        }
        guard let thankYouId = sections.getSafely(at: indexPath.section)?.thankYouList.getSafely(at: indexPath.row)?.id,
              let height = estimatedRowHeights[thankYouId] else {
            return tableView.estimatedRowHeight
        }
        return height
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard hasLoadedThankYouList else { return }
        cell.contentView.updateConstraintsIfNeeded()
        if let thankYouId =  sections.getSafely(at: indexPath.section)?.thankYouList.getSafely(at: indexPath.row)?.id {
            estimatedRowHeights[thankYouId] = cell.frame.size.height
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollIndicator?.scrollViewDidScroll()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollIndicator.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollIndicator.scrollViewDidEndDecelerating(scrollView)
    }
}

// MARK: - ListScrollIndicatorDelegate
extension ThankYouListViewController: ListScrollIndicatorDelegate {
    func listScrollIndicatorDidBeginDraggingMovableIcon(_ indicator: ListScrollIndicator) {
        guard let user = Auth.auth().currentUser else { return }
        analyticsManager.logEvent(
            eventName: AnalyticsEventConst.startDraggingListScrollIndicatorMovableIcon,
            userId: user.uid)
    }
}

// MARK: - ThankYouCellDelegate
extension ThankYouListViewController: ThankYouCellDelegate {
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
extension ThankYouListViewController: BottomHalfSheetMenuViewControllerDelegate {
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
