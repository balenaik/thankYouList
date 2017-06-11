//
//  ViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 4/11/17.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    
    
    @IBOutlet weak var tableView: UITableView!

    
    
    @IBAction func addButton(_ sender: Any) {
        
        // 入力画面に遷移
        let storyboard: UIStoryboard = self.storyboard!
        let addThankYouDataVC = storyboard.instantiateViewController(withIdentifier: "addThankYouDataVC") as! ThankYouList.AddThankYouDataVC
        let navi = UINavigationController(rootViewController: addThankYouDataVC)
        self.present(navi, animated: true, completion: nil)
        

    }
    

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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

    
    
    // the function for getting section items
    func getSectionItems(section: Int) -> [ThankYouData] {
        var sectionItems = [ThankYouData]()
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        
        // ThankYouを格納した配列
        let thankYouDataList: [ThankYouData] = thankYouDataSingleton.thankYouDataList
        // Sectionで利用する配列
        var sectionDate: [String] = thankYouDataSingleton.sectionDate
        
        // Loop through the thankYouDataList to get the items for this section's date
        for item in thankYouDataList {
            let thankYouData = item as ThankYouData
            
            // If the item's date equals the section's date then add it
            if thankYouData.thankYouDate == sectionDate[section] {
                sectionItems.append(thankYouData)
            }
        }
        return sectionItems
    }
    
    

    
    // テーブルの行数を返却する
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.getSectionItems(section: section).count)
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
        return cell 
    }
    
    
    /*
     セクションの数を返す.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        // Get the singleton
        print(GlobalThankYouData.sharedInstance)
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        print(thankYouDataSingleton)
        // Sectionで利用する配列
        let sectionDate: [String] = thankYouDataSingleton.sectionDate
        print(sectionDate.count)
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
    
    
    // reload again
    override func viewWillAppear(_ animated: Bool) {
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        print("thankYouDataList.count:", thankYouDataSingleton.thankYouDataList.count)
        self.tableView.reloadData()
    }
    
    
    /**
     　　本日を書式指定して文字列で取得
     
     - parameter format: 書式（オプション）。未指定時は"yyyy/MM/dd"
     - returns: 本日の日付
     */
    func getToday(format:String = "yyyy/MM/dd") -> String {
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: now as Date)
    }
}

