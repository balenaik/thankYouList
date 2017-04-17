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
    var thankYouList = [String]()
    
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
                self.thankYouList.insert(textField.text!, at: 0)
                
                // テーブルに行が追加されたことをテーブルに通知
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)],
                                          with: UITableViewRowAnimation.right)
                
                // ThankYouの保存処理
                let userDefaults = UserDefaults.standard
                userDefaults.set(self.thankYouList, forKey: "thankYouList")
                userDefaults.synchronize()
            }
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
        if let storedThankYouList = userDefaults.array(forKey: "thankYouList") as? [String] {
            thankYouList.append(contentsOf: storedThankYouList)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    // テーブルの行数を返却する
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ThankyouListの配列の長さを返却する
        return thankYouList.count
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Storyboardで指定したthankyouCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "thankYouCell", for: indexPath)
        
        // 行番号にあったThankYouのタイトルを取得
        let thankYouTitle = thankYouList[indexPath.row]
        // セルのラベルにthankYouのタイトルをセット
        cell.textLabel?.text = thankYouTitle
        return cell
    }

}

