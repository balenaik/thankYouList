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

class ViewController: UIViewController {
    
    // MARK: - Properties
    private var delegate = UIApplication.shared.delegate as! AppDelegate
    private var db = Firestore.firestore()
    private var thankYouDataSingleton = GlobalThankYouData.sharedInstance
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!


    // MARK: - IBActions
    @IBAction func tappedMenuButton(_ sender: Any) {
        slideMenuController()?.openLeft()
    }
    
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        loadThankYouData()
        checkForUpdates()
        
        // change the height of cells depending on the text
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        // tableviewの背景色指定
        self.view.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        
        // navigationbarの背景色指定
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 255/255.0, green: 248/255.0, blue: 232/255.0, alpha: 1.0)
        
        // navigationbarの文字色設定
        self.navigationController?.navigationBar.tintColor = UIColor(red: 254/255.0, green: 147/255.0, blue: 157/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor(red: 254/255.0, green: 147/255.0, blue: 157/255.0, alpha: 1.0)]
        
        if thankYouDataSingleton.thankYouDataList.count != 0 { return }

        let userDefaults = UserDefaults.standard
        if let storedThankYouDataList = userDefaults.object(forKey: "thankYouDataList") as? Data {
            
//            if let unarchiveThankYouDataList = NSKeyedUnarchiver.unarchiveObject(
//                with: storedThankYouDataList) as? [ThankYouDataUD] {
//                thankYouDataSingleton.thankYouDataList.append(contentsOf: unarchiveThankYouDataList)
//            }
        }
        if let storedSectionDate = userDefaults.array(forKey: "sectionDate") as? [String] {
            thankYouDataSingleton.sectionDate.append(contentsOf: storedSectionDate)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        print("thankYouDataList.count:", thankYouDataSingleton.thankYouDataList.count)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        Auth.auth().removeStateDidChangeListener(handle!)
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
        guard let userMail = Auth.auth().currentUser?.email else {
            print("Not login? error")
            return
        }
        thankYouDataSingleton.sectionDate = []
        db.collection("users").document(userMail).collection("posts").getDocuments { [weak self](querySnapshot, error) in
            guard let weakSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            var thankYouDataList: [ThankYouData] = []
            for document in querySnapshot.documents {
                guard var thankYouData = ThankYouData(dictionary: document.data()) else { break }
                thankYouData.id = document.documentID
                thankYouDataList.append(thankYouData)
            }
            for thankYouData in thankYouDataList {
                if !weakSelf.thankYouDataSingleton.sectionDate.contains(thankYouData.date) {
                    weakSelf.thankYouDataSingleton.sectionDate.append(thankYouData.date)
                }
            }
            weakSelf.thankYouDataSingleton.thankYouDataList = thankYouDataList
            DispatchQueue.main.async {
                weakSelf.tableView.reloadData()
            }
        }
    }
    
    private func checkForUpdates() {
        guard let userMail = Auth.auth().currentUser?.email else {
            print("Not login? error")
            return
        }
        db.collection("users").document(userMail).collection("posts").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let weakSelf = self else { return }
            guard let snapShot = querySnapshot else { return }
            // TODO: sectionDate
            for diff in snapShot.documentChanges {
                if diff.type == .added {
                    let thankYouData = ThankYouData(dictionary: diff.document.data())
                    guard var newThankYouData = thankYouData else { break }
                    newThankYouData.id = diff.document.documentID
                    let thankYouDataIds: [String] = weakSelf.thankYouDataSingleton.thankYouDataList.map{$0.id}
                    if !thankYouDataIds.contains(newThankYouData.id) {
                         weakSelf.thankYouDataSingleton.thankYouDataList.append(newThankYouData)
                    }
                }
                if diff.type == .removed {
                    let removedDataId = diff.document.documentID
                    for (index, thankYouDataList) in weakSelf.thankYouDataSingleton.thankYouDataList.enumerated() {
                        if thankYouDataList.id == removedDataId {
                            weakSelf.thankYouDataSingleton.thankYouDataList.remove(at: index)
                            break
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                weakSelf.tableView.reloadData()
            }
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
        let sectionItems = self.getSectionItems(section: indexPath.section)
        let myThankYouData = sectionItems[indexPath.row]

        cell.textLabel?.text = myThankYouData.value
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = TYLColor.textColor
        return cell 
    }
    
    
    /*
     セクションの数を返す.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        // Sectionで利用する配列
        let sectionDate: [String] = thankYouDataSingleton.sectionDate
        return sectionDate.count
    }
    
    /*
     セクションのタイトルを返す.
     */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        // Sectionで利用する配列
        var sectionDate: [String] = thankYouDataSingleton.sectionDate
        return sectionDate[section]
    }
    
    /*
     セクションの背景色を変更する
    */
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
        // Input the indexPath in the indexPath in AppDelegate
        print("didSelectRowAt in View Controller is called")
        self.delegate.indexPathSection = indexPath.section
        self.delegate.indexPathRow = indexPath.row
        // going to the edit page
        let storyboard: UIStoryboard = self.storyboard!
        let editThankYouDataVC = storyboard.instantiateViewController(withIdentifier: "editThankYouDataVC") as! ThankYouList.EditThankYouDataVC
        let navi = UINavigationController(rootViewController: editThankYouDataVC)
        self.present(navi, animated: true, completion: nil)
    }
}



