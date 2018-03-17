//
//  ViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 4/11/17.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//    var handle: AuthStateDidChangeListenerHandle?
    let textColor = UIColor(colorWithHexValue: 0x3a3a3a)
    
    @IBOutlet weak var tableView: UITableView!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a new document with a generated ID
//        var ref: DocumentReference? = nil
//        let db: Firestore! = Firestore.firestore()
//        ref = db.collection("users").addDocument(data: [
//            "first": "Ada",
//            "last": "Lovelace",
//            "born": 1815
//        ]) { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//            }
//        }
        
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
        
        
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        

        
        // 保存しているThankYouの読み込み処理
        let userDefaults = UserDefaults.standard
        if let storedThankYouDataList = userDefaults.object(forKey: "thankYouDataList") as? Data {
            
            if let unarchiveThankYouDataList = NSKeyedUnarchiver.unarchiveObject(
                with: storedThankYouDataList) as? [ThankYouData] {
                thankYouDataSingleton.thankYouDataList.append(contentsOf: unarchiveThankYouDataList)
            }
        }
        if let storedSectionDate = userDefaults.array(forKey: "sectionDate") as? [String] {
            thankYouDataSingleton.sectionDate.append(contentsOf: storedSectionDate)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        Auth.auth().removeStateDidChangeListener(handle!)
    }

    
    
    // the function for getting section items
    func getSectionItems(section: Int) -> [ThankYouData] {
        var sectionItems = [ThankYouData]()
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        
        // ThankYouを格納した配列
        let thankYouDataList: [ThankYouData] = thankYouDataSingleton.thankYouDataList
        // Sectionで利用する配列
        var sectionDate: [String] = thankYouDataSingleton.sectionDate
        // Set sectionItems
        sectionItems = thankYouDataList.filter({$0.thankYouDate == sectionDate[section]})

        return sectionItems
    }
    
    

    
    // テーブルの行数を返却する
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getSectionItems(section: section).count
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Storyboardで指定したthankyouCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "thankYouCell", for: indexPath)
        // get the items in this section
        let sectionItems = self.getSectionItems(section: indexPath.section)
        // 行番号にあったThankYouのタイトルを取得 & get the item for the row in this section
        let myThankYouData = sectionItems[indexPath.row]
        
        // セルのラベルにthankYouのタイトルをセット
        cell.textLabel?.text = myThankYouData.thankYouValue
        // change the text size
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = textColor
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
    
    
    // reload again
    override func viewWillAppear(_ animated: Bool) {
//        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
//            // ...
//        }
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        print("thankYouDataList.count:", thankYouDataSingleton.thankYouDataList.count)
        self.tableView.reloadData()
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
    
    
    
    /**
     　　本日を書式指定して文字列で取得
     
     - parameter format: 書式（オプション）。未指定時は"yyyy/MM/dd"
     - returns: 本日の日付
     */
    func getToday(format:String = "yyyy/MM/dd") -> String {
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter.string(from: now as Date)
    }
}



