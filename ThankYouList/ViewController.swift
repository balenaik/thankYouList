//
//  ViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 4/11/17.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //ThankYouを格納した配列
    var thankYouDataList = [ThankYouData]()
    
    // Sectionで利用する配列
    var sectionDate: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addButton(_ sender: Any) {
        // アラートダイアログを生成
        let alertController = UIAlertController(title: "THANKYOU追加",
                                                message: "ありがとうを入力してください",
                                                preferredStyle: UIAlertControllerStyle.alert)
        // テキストエリアを追加
        alertController.addTextField(configurationHandler: nil)
        // OKボタンを追加
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (action:UIAlertAction) in
            // OKボタンがタップされたときの処理
            if let textField = alertController.textFields?.first {
                // THANKYOULISTの配列に入力値を挿入。先頭に挿入する。
                let myThankYouData = ThankYouData()
                myThankYouData.thankYouValue = textField.text!
                myThankYouData.thankYouDate = self.getToday()
                
                print(myThankYouData.thankYouDate!)
                print(myThankYouData.thankYouValue!)
                
                //section
                let sections: NSSet = NSSet(array: self.sectionDate)
                
                // if sectionDate doesn't contain the thankYouDate, then add it
                if !sections.contains(myThankYouData.thankYouDate!) {
                    self.sectionDate.append(myThankYouData.thankYouDate!)
                    print("sectiondate.append happens")
                }
                
                //Insert
                self.thankYouDataList.insert(myThankYouData, at: 0)

                
                //print(self.thankYouDataList[0].thankYouValue!)
                //print(self.sectionDate[0])
                //print(self.sectionDate[1])
                //print(self.sectionDate[2])
                
                // テーブルに行が追加されたことをテーブルに通知
              //  self.tableView.insertSections(NSIndexSet(index: 1) as IndexSet, with: UITableViewRowAnimation.right)
               // self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)],
                //                          with: UITableViewRowAnimation.right)

                
                //print(self.tableView.)
                // ThankYouの保存処理
                let userDefaults = UserDefaults.standard
                // Data型にシリアライズする
                let data = NSKeyedArchiver.archivedData(withRootObject: self.thankYouDataList)
                userDefaults.set(data, forKey: "thankYouDataList")
                userDefaults.set(self.sectionDate, forKey: "sectionDate")
                userDefaults.synchronize()
            }
            // UserDefaultsに保存後の再読み込み処理
            self.tableView.reloadData()
        }
        
        // OKボタんを追加
        alertController.addAction(okAction)
        
        //Cancelボタンがタップされた時の処理
        let cancelButton = UIAlertAction(title: "CANCEL",
                                         style: UIAlertActionStyle.cancel, handler:nil)
        // Cancelボタんを追加
        alertController.addAction(cancelButton)
        
        // Alertdialogを表示
        present(alertController, animated:true, completion: nil)
        
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // 保存しているThankYouの読み込み処理
        let userDefaults = UserDefaults.standard
        if let storedThankYouDataList = userDefaults.object(forKey: "thankYouDataList") as? Data {
            
            if let unarchiveThankYouDataList = NSKeyedUnarchiver.unarchiveObject(
                with: storedThankYouDataList) as? [ThankYouData] {
                thankYouDataList.append(contentsOf: unarchiveThankYouDataList)
                
                /**
                // セクションに日付を格納していく
                var tmpSectionDate = [String]()
                for index in 0...thankYouDataList.count-1 {
                    tmpSectionDate.insert(thankYouDataList[index].thankYouDate!, at: index)
                }
                let tmpSectionDate2 = NSOrderedSet(array: tmpSectionDate)
                // 重複日付の削除完了
                sectionDate = tmpSectionDate2.array as! [String]
                **/
            
            }
        }
        if let storedSectionDate = userDefaults.array(forKey: "sectionDate") as? [String] {
            sectionDate.append(contentsOf: storedSectionDate)
        }
        //print(self.thankYouDataList[0].thankYouValue!)
        //print(self.sectionDate[0])
        //print(sectionDate.count)
        //print(self.getSectionItems(section: 2))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // the function for getting section items
    func getSectionItems(section: Int) -> [ThankYouData] {
        var sectionItems = [ThankYouData]()
        
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
      /**
        var count = 0
        // section数の分forでループ
        for index in 0...sectionDate.count {
            if index == 0 {
                return 0
            } else {
                if section == index {
                    for (i, thankYouDataList) in thankYouDataList.enumerated() {
                        if thankYouDataList.thankYouDate == sectionDate[index] {
                            //let tmpSection = thankYouDataList.filter {$0.thankYouDate == sectionDate[index]} {
                            count = count + 1
                        }
                        return count
                    }
                }
            }
        }
        return 0
 **/
        
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
        // ( it was used to be "thankYouData[indexPath.row] )
        
        // セルのラベルにthankYouのタイトルをセット
        cell.textLabel?.text = myThankYouData.thankYouValue
        return cell
    }
    
    
    /*
     セクションの数を返す.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDate.count
    }
    
    /*
     セクションのタイトルを返す.
     */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      //  if section < 1 {
      //      return "なし"
      //  } else {
            return sectionDate[section]
      //  }
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

