//
//  AddThankYouDataVC.swift
//  ThankYouList
//
//  Created by Aika Yamada on 5/15/17.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit

class AddThankYouDataVC: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var thankYouDatePicker: UIDatePicker!
    @IBOutlet weak var addThankYou: UINavigationItem!
    @IBOutlet weak var thankYouTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var textViewCell: UITableViewCell!
    @IBOutlet weak var dateCell: UITableViewCell!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    
    // datePickerの表示状態
    private var _datePickerIsShowing = false
    // datePicker表示時のセルの高さ
    private let _DATEPICKER_CELL_HEIGHT: CGFloat = 210
    
    
    @IBAction func goBack(_ sender: Any) {
        // Return
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func add(_ sender: Any) {
        
        // when 'Done' button is tapped
        // if thankYouTextView is not empty
        if (!thankYouTextView.isEqual("")) {
            
            // thankYouDataクラスに格納
            let myThankYouData = ThankYouData()
            myThankYouData.thankYouValue = thankYouTextView.text
            myThankYouData.thankYouDate = self.dateLabel.text
            
            
            
            // addします
            addThankYou(thankYouData: myThankYouData)
            
        
            
            // Go back to the previous screen
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    func addThankYou(thankYouData: ThankYouData) -> Void{
        
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        
        
        //section
        let sections: NSSet = NSSet(array: thankYouDataSingleton.sectionDate)
        
        // if sectionDate doesn't contain the thankYouDate, then add it
        if !sections.contains(thankYouData.thankYouDate!) {
            thankYouDataSingleton.sectionDate.append(thankYouData.thankYouDate!)
            print("sectiondate.append happens")
        }
        
        // Sort the sectionDate
        thankYouDataSingleton.sectionDate.sort(by:>)
        print(thankYouDataSingleton.sectionDate[0])
        
        //Insert
        thankYouDataSingleton.thankYouDataList.insert(thankYouData, at: 0)
        
        // ThankYouの保存処理
        let userDefaults = UserDefaults.standard
        // Data型にシリアライズする
        let data = NSKeyedArchiver.archivedData(withRootObject: thankYouDataSingleton.thankYouDataList)
        userDefaults.set(data, forKey: "thankYouDataList")
        userDefaults.set(thankYouDataSingleton.sectionDate, forKey: "sectionDate")
        userDefaults.synchronize()
        

        
        
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
    
    func showDatePickerCell() {
        // フラグの更新
        self._datePickerIsShowing = true
        
        //　datePickerを表示する。
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        self.thankYouDatePicker.isHidden = false
        self.thankYouDatePicker.alpha = 0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.thankYouDatePicker.alpha = 1.0
        }, completion: {(Bool) -> Void in
            
        })
    }


    func hideDatePickerCell() {
        // フラグの更新
        self._datePickerIsShowing = false
        
        //　datePickerを非表示する。
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        UIView.animate(withDuration: 0.25,
                                   animations: {() -> Void in
                                    self.thankYouDatePicker.alpha = 0
        }, completion: {(Bool) -> Void in
            self.thankYouDatePicker.isHidden = true
        })
    }

    
    func dspDatePicker() {
        print("dspDatePicker()")
        // フラグを見て、切り替える
        if (self._datePickerIsShowing){
            hideDatePickerCell()
        } else {
            showDatePickerCell()
        }
    }

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        // put today on dateLabel
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let nowString = formatter.string(from: now as Date)
        dateLabel.text = nowString
        
        // 使用するセルを登録
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "datePickerCell")
        //　UITextFieldと、UIDatePickerを生成する。
//        self._dataInput = UITextField()
//        self._datePicker = UIDatePicker()

        
        
        thankYouTextView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 10000
        
        thankYouTextView.becomeFirstResponder()
        
        thankYouDatePicker.addTarget(self, action: #selector(AddThankYouDataVC.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func datePickerValueChanged (thankYouDatePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateValue = dateFormatter.string(from: thankYouDatePicker.date)
        dateLabel.text = dateValue
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1) {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat =  self.tableView.rowHeight
        
        if(indexPath.section == 1 && indexPath.row == 1) {
            print("sec1row1")
            //　DatePicker行の場合は、DatePickerの表示状態に応じて高さを返す。
            // 表示の場合は、表示で指定している高さを、非表示の場合は０を返す。
            height =  self._datePickerIsShowing ? self._DATEPICKER_CELL_HEIGHT : CGFloat(0)
        }
        return height
        //return UITableViewAutomaticDimension
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell", for: indexPath)
        var cell = textViewCell
        
        if (indexPath.section == 1 && indexPath.row == 0) {
            cell = dateCell
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            cell = datePickerCell
        }
            return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルを選択した時に日付があったらDatePickerの表示切り替えを行う
        if(indexPath.section == 1 && indexPath.row == 0) {
            print("sec1row0")
            dspDatePicker()
            thankYouTextView.endEditing(true)
        }
        // セルがタップされても残らないように設定
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
