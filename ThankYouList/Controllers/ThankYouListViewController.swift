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
import JGProgressHUD

class ThankYouListViewController: UIViewController {
    
    // MARK: - Struct
    struct Section {
        /// yyyy/MM (String)
        var sectionDateString: String
        var displayDateString: String
        var thankYouList: [ThankYouData]
    }
    
    // MARK: - Properties
    private var delegate = UIApplication.shared.delegate as! AppDelegate
    private var db = Firestore.firestore()
    private var thankYouDataSingleton = GlobalThankYouData.sharedInstance
    private var sections = [Section]()
    private let loadingHud = JGProgressHUD(style: .extraLight)
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: EmptyView!
    
    

    // MARK: - IBActions
    @IBAction func tappedMenuButton(_ sender: Any) {
        slideMenuController()?.openLeft()
    }
    
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingHud.textLabel.text = "Loading"
        loadingHud.show(in: self.view)
        
        sections = []
        loadThankYouData()
        checkForUpdates()
        
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension

        emptyView.isHidden = true
        
        self.navigationController?.navigationBar.barTintColor = TYLColor.navigationBarBgColor
        self.navigationController?.navigationBar.tintColor = TYLColor.navigationBarTextColor
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : TYLColor.navigationBarTextColor
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
    

// MARK: - Private Methods
extension ThankYouListViewController {
    private func loadThankYouData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Not login? error")
            return
        }
        let uid16string = String(uid.prefix(16))
        db.collection("users").document(uid).collection("thankYouList").getDocuments { [weak self](querySnapshot, error) in
            guard let weakSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                weakSelf.loadingHud.dismiss(animated: true)
                return
            }
            guard let querySnapshot = querySnapshot else {
                weakSelf.loadingHud.dismiss(animated: true)
                return
            }
            var thankYouDataList: [ThankYouData] = []
            for document in querySnapshot.documents {
                guard var thankYouData = ThankYouData(dictionary: document.data()) else { break }
                let decryptedValue = Crypto().decryptString(encryptText: thankYouData.encryptedValue, key: uid16string)
                thankYouData.id = document.documentID
                thankYouData.value = decryptedValue
                thankYouDataList.append(thankYouData)
            }
            for thankYouData in thankYouDataList {
                weakSelf.addThankYouDataToSection(thankYouData: thankYouData)
            }
            weakSelf.thankYouDataSingleton.thankYouDataList = thankYouDataList
            DispatchQueue.main.async {
                if weakSelf.thankYouDataSingleton.thankYouDataList.count == 0 {
                    weakSelf.emptyView.isHidden = false
                } else {
                    weakSelf.emptyView.isHidden = true
                }
                weakSelf.loadingHud.dismiss(animated: true)
                weakSelf.tableView.reloadData()
            }
        }
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
                weakSelf.loadingHud.dismiss(animated: true)
                return
            }
            guard let snapShot = querySnapshot else {
                weakSelf.loadingHud.dismiss(animated: true)
                return
            }
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
                    weakSelf.addThankYouDataToSection(thankYouData: newThankYouData)
                }
                if diff.type == .removed {
                    let removedDataId = diff.document.documentID
                    for (index, thankYouData) in weakSelf.thankYouDataSingleton.thankYouDataList.enumerated() {
                        if thankYouData.id == removedDataId {
                            weakSelf.thankYouDataSingleton.thankYouDataList.remove(at: index)
                            weakSelf.deleteThankYouDataFromSection(thankYouData: thankYouData)
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
                            weakSelf.deleteThankYouDataFromSection(thankYouData: thankYouData)
                            break
                        }
                    }
                    weakSelf.thankYouDataSingleton.thankYouDataList.append(editedThankYouData)
                    weakSelf.addThankYouDataToSection(thankYouData: editedThankYouData)
                }
            }
            DispatchQueue.main.async {
                if weakSelf.thankYouDataSingleton.thankYouDataList.count == 0 {
                    weakSelf.emptyView.isHidden = false
                } else {
                    weakSelf.emptyView.isHidden = true
                }
                weakSelf.loadingHud.dismiss(animated: true)
                weakSelf.postNotificationThankYouListUpdated()
                weakSelf.tableView.reloadData()
            }
        }
    }
    
    private func postNotificationThankYouListUpdated() {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NotificationConst.THANK_YOU_LIST_UPDATED), object: nil, userInfo: nil))
    }
    
    private func addThankYouDataToSection(thankYouData: ThankYouData) {
        /// Crop only year and month (yyyy/MM) from thank you date
        let dateYearMonthString = String(thankYouData.date.prefix(7))
        let sectionIndex = sections.index(where: {$0.sectionDateString == dateYearMonthString})
        if let index = sectionIndex {
            sections[index].thankYouList.append(thankYouData)
        } else {
            guard let dateYearMonth = dateYearMonthString.toYearMonthDate() else { return }
            let newSection = Section(sectionDateString: dateYearMonthString,
                                     displayDateString: dateYearMonth.toYearMonthString(),
                                     thankYouList: [thankYouData])
            sections.append(newSection)
            sections.sort(by: {$0.displayDateString > $1.displayDateString})
        }
    }
    
    private func deleteThankYouDataFromSection(thankYouData: ThankYouData) {
        /// Crop only year and month (yyyy/MM) from thank you date
        let dateYearMonthString = String(thankYouData.date.prefix(7))
        /// If there is no section or thank you id matching, do nothing
        guard let sectionIndex = sections.index(where: {$0.sectionDateString == dateYearMonthString}),
            let thankYouIndex = sections[sectionIndex].thankYouList
                .index(where: {$0.id == thankYouData.id}) else { return }
        sections[sectionIndex].thankYouList.remove(at: thankYouIndex)
        if sections[sectionIndex].thankYouList.count == 0 {
            sections.remove(at: sectionIndex)
        }
    }
}
    
    
// MARK: - UITableViewDataSource & UITableViewDelegate
extension ThankYouListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].thankYouList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "thankYouCell", for: indexPath)
        let thankYouData = sections[indexPath.section].thankYouList[indexPath.row]
        cell.textLabel?.text = thankYouData.value
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = TYLColor.textColor
        return cell 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // 余白を作る(UIViewをセクションのビューに指定（だからxとかy指定しても意味ない）
        let view = UIView(frame: CGRect(x:0, y:0, width:20, height:20))
        view.backgroundColor = UIColor(red: 252/255.0, green: 181/255.0, blue: 181/255.0, alpha: 1.0)
        let label :UILabel = UILabel(frame: CGRect(x: 15, y: 7.5, width: tableView.frame.width, height: 20))
        label.textColor = UIColor.white
        label.text = sections[section].displayDateString
        view.addSubview(label)
        return view
    }
    
    // when a cell is tapped it goes the edit screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editingThankYouData = sections[indexPath.section].thankYouList[indexPath.row]
        let vc = EditThankYouViewController.createViewController(thankYouData: editingThankYouData)
        let navi = UINavigationController(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
}



