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

class ThankYouListViewController: UIViewController {

    struct Section {
        /// yyyy/MM (String)
        var sectionDateString: String
        var displayDateString: String
        var thankYouList: [ThankYouData]
    }

    private var db = Firestore.firestore()
    private var thankYouDataSingleton = GlobalThankYouData.sharedInstance
    private var sections = [Section]()
    private var estimatedRowHeights = [String : CGFloat]()

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
        guard let myPageViewController = MyPageViewController.createViewController() else { return }
        present(myPageViewController, animated: true, completion: nil)
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
                return
            }
            guard let snapShot = querySnapshot else {
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
        let sectionIndex = sections.index(where: {$0.sectionDateString == dateYearMonthString})
        if let index = sectionIndex {
            sections[index].thankYouList.append(thankYouData)
            sections[index].thankYouList.sort(by: {$0.date > $1.date})
        } else {
            guard let dateYearMonth = dateYearMonthString.toYearMonthDate() else { return }
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
        guard let sectionIndex = sections.index(where: {$0.sectionDateString == dateYearMonthString}),
            let thankYouIndex = sections[sectionIndex].thankYouList
                .index(where: {$0.id == thankYouData.id}) else { return }
        sections[sectionIndex].thankYouList.remove(at: thankYouIndex)
        if sections[sectionIndex].thankYouList.count == 0 {
            sections.remove(at: sectionIndex)
        }
    }
}
    
    
// MARK: - UITableViewDataSource
extension ThankYouListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].thankYouList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.thankYouCell, for: indexPath)!
        let thankYouData = sections[indexPath.section].thankYouList[indexPath.row]
        cell.bind(thankYouData: thankYouData)
        cell.delegate = self
        scrollIndicator.bind(title: sections[indexPath.section].displayDateString)
        cell.selectionStyle = .none
        return cell 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editingThankYouData = sections[indexPath.section].thankYouList[indexPath.row]
        let vc = EditThankYouViewController.createViewController(thankYouData: editingThankYouData)
        let navi = UINavigationController(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension ThankYouListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ListSectionHeaderView.cellIdentifier()) as! ListSectionHeaderView
        header.bind(sectionString: sections[section].displayDateString)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ListSectionHeaderView.cellHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let thankYouId =  sections[indexPath.section].thankYouList[indexPath.row].id
        if let height = estimatedRowHeights[thankYouId] {
            return height
        }
        return tableView.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.updateConstraints()
        let thankYouId =  sections[indexPath.section].thankYouList[indexPath.row].id
        estimatedRowHeights[thankYouId] = cell.frame.size.height
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
        Analytics.logEvent(eventName: AnalyticsEventConst.startDraggingListScrollIndicatorMovableIcon, userId: user.uid)
    }
}

// MARK: - ThankYouCellDelegate
extension ThankYouListViewController: ThankYouCellDelegate {
    func thankYouCellDidTapThankYouView() {
    }
}

// MARK: - Public
extension ThankYouListViewController {
    static func createViewController() -> UIViewController? {
        guard let viewController = R.storyboard.thankYouList().instantiateInitialViewController() else { return nil }
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
