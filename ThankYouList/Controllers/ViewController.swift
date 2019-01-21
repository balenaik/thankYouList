//
//  ViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 4/11/17.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import JGProgressHUD

class ViewController: UIViewController {
    
    // MARK: - Properties
    private var delegate = UIApplication.shared.delegate as! AppDelegate
    private var db = Firestore.firestore()
    private var thankYouDataSingleton = GlobalThankYouData.sharedInstance
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
        
        loadThankYouData()
        checkForUpdates()
        
        // change the height of cells depending on the text
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension

        emptyView.isHidden = true
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 255/255.0, green: 248/255.0, blue: 232/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 254/255.0, green: 147/255.0, blue: 157/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(red: 254/255.0, green: 147/255.0, blue: 157/255.0, alpha: 1.0)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        Auth.auth().removeStateDidChangeListener(handle!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Private Methods
    private func getSectionItems(section: Int) -> [ThankYouData] {
        var sectionItems = [ThankYouData]()
        let thankYouDataSingleton = GlobalThankYouData.sharedInstance
        let thankYouDataList: [ThankYouData] = thankYouDataSingleton.thankYouDataList
        var sectionDate: [String] = thankYouDataSingleton.sectionDate
        sectionItems = thankYouDataList.filter({$0.date == sectionDate[section]})

        return sectionItems
    }
    
    private func loadThankYouData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Not login? error")
            return
        }
        let uid16string = String(uid.prefix(16))
        thankYouDataSingleton.sectionDate = []
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
                if !weakSelf.thankYouDataSingleton.sectionDate.contains(thankYouData.date) {
                    weakSelf.thankYouDataSingleton.sectionDate.append(thankYouData.date)
                }
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
    
    private func deleteSectionDateIfNeeded(sectionDate: String) {
        let sectionItemsCount = thankYouDataSingleton.thankYouDataList.filter({$0.date == sectionDate}).count
        if sectionItemsCount == 0 {
            thankYouDataSingleton.sectionDate = thankYouDataSingleton.sectionDate.filter({$0 != sectionDate})
            thankYouDataSingleton.sectionDate.sort(by:>)
        }
    }
}
    
    
// MARK: - Extensions
extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSectionItems(section: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "thankYouCell", for: indexPath)
        let sectionItems = getSectionItems(section: indexPath.section)
        let myThankYouData = sectionItems[indexPath.row]

        cell.textLabel?.text = myThankYouData.value
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = TYLColor.textColor
        return cell 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        // Sectionで利用する配列
        let sectionDate: [String] = thankYouDataSingleton.sectionDate
        return sectionDate.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        // Sectionで利用する配列
        var sectionDate: [String] = thankYouDataSingleton.sectionDate
        return sectionDate[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        // Sectionで利用する配列
        var sectionDate: [String] = thankYouDataSingleton.sectionDate
        // 余白を作る(UIViewをセクションのビューに指定（だからxとかy指定しても意味ない）
        let view = UIView(frame: CGRect(x:0, y:0, width:20, height:20))
        view.backgroundColor = UIColor(red: 252/255.0, green: 181/255.0, blue: 181/255.0, alpha: 1.0)
        let label :UILabel = UILabel(frame: CGRect(x: 15, y: 7.5, width: tableView.frame.width, height: 20))
        label.textColor = UIColor.white
        label.text = sectionDate[section]
        //指定したlabelをセクションビューのサブビューに指定
        view.addSubview(label)
        return view
    }
    
    
    // when a cell is tapped it goes the edit screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionItems = self.getSectionItems(section: indexPath.section)
        let editingThankYouData = sectionItems[indexPath.row]
        let vc = EditThankYouDataVC.createViewController(thankYouData: editingThankYouData)
        let navi = UINavigationController(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
}



