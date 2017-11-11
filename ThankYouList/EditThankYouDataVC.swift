//
//  EditThankYouDataVC.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2017/06/24.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit

class EditThankYouDataVC: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var thankYouDatePicker: UIDatePicker!
    @IBOutlet weak var editThankYou: UINavigationItem!
    @IBOutlet weak var thankYouTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var textViewCell: UITableViewCell!
    @IBOutlet weak var dateCell: UITableViewCell!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var tableViewCell: UITableViewCell!
    @IBOutlet weak var deleteCell: UITableViewCell!
    
    
    var delegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // datePickerの表示状態
    private var _datePickerIsShowing = false
    // datePicker表示時のセルの高さ
    private let _DATEPICKER_CELL_HEIGHT: CGFloat = 210
    
    
    @IBAction func goBack(_ sender: Any) {
        // Return
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func edit(_ sender: Any) {
        // when 'Done' button is tapped
        // if thankYouTextView is not empty
        if (!thankYouTextView.text.isEqual("") || !thankYouTextView.text.isEmpty) {
            // thankYouDataクラスに格納
            let myThankYouData = ThankYouData()
            myThankYouData.thankYouValue = thankYouTextView.text
            myThankYouData.thankYouDate = self.dateLabel.text
            
            // editします
            editThankYou(editThankYouData: myThankYouData)

            
            // Go back to the previous screen
            self.dismiss(animated: true, completion: nil)
            
        }
    }

    
    
    
    func editThankYou(editThankYouData: ThankYouData) -> Void{

        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        
        // ******SECTIONDATE********
        // if sectionDate doesn't contain the thankYouDate, then add it
        if !thankYouDataSingleton.sectionDate.contains(editThankYouData.thankYouDate!) {
            thankYouDataSingleton.sectionDate.append(editThankYouData.thankYouDate!)
        }
        // **************************
        
        // ThankYouを格納した配列
        let thankYouDataList: [ThankYouData] = thankYouDataSingleton.thankYouDataList
        // Sectionで利用する配列
        var sectionDate: [String] = thankYouDataSingleton.sectionDate
        
        var sectionAmt: Int = 0
        
        // Loop through the thankYouDataList to get the number of items for the ex-item's section date
        for item in thankYouDataList {
            let thankYouData = item as ThankYouData
            // If the item's date equals the section's date then add it
            if thankYouData.thankYouDate == sectionDate[self.delegate.indexPathSection!] {
                sectionAmt = sectionAmt + 1
            }
        }

        // if the ex-thankYouDate was the only one in the section, delete the section
        if sectionAmt == 1 && editThankYouData.thankYouDate != sectionDate[self.delegate.indexPathSection!] {
            thankYouDataSingleton.sectionDate.remove(at: self.delegate.indexPathSection!)
        }
        
        // Sort the sectionDate
        thankYouDataSingleton.sectionDate.sort(by:>)
        
        // Get the index number in thankYouDataList
        var listIndexNo: Int = 0
        
        // count
        var rowCount: Int = 0

        // Loop through the array till the data matches and get the element at the selected row number
        for (index, item) in thankYouDataList.enumerated() {
            let thankYouData = item as ThankYouData

            // if thankYouDate from the item equals to the data in array, then get the index number.
            if thankYouData.thankYouDate! == sectionDate[self.delegate.indexPathSection!] {
                rowCount = rowCount + 1
            }
            
            // if rowCount reachs indexPath.row, then exit the loop.
            if rowCount == self.delegate.indexPathRow! + 1 {
                listIndexNo = index
                
                break
            }
        }

        // Delete the element first
        thankYouDataSingleton.thankYouDataList.remove(at: listIndexNo)

        // Edit thankYouData
        thankYouDataSingleton.thankYouDataList.insert(editThankYouData, at: listIndexNo)
        
        // ThankYouの保存処理
        let userDefaults = UserDefaults.standard
        // Data型にシリアライズする
        let data = NSKeyedArchiver.archivedData(withRootObject: thankYouDataSingleton.thankYouDataList)
        userDefaults.set(data, forKey: "thankYouDataList")
        userDefaults.set(thankYouDataSingleton.sectionDate, forKey: "sectionDate")
        userDefaults.synchronize()
        
    }
    
    func deleteThankYou() -> Void {

    
        // Get the singleton
        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
        // ThankYouを格納した配列
        let thankYouDataList: [ThankYouData] = thankYouDataSingleton.thankYouDataList
        // Sectionで利用する配列
        var sectionDate: [String] = thankYouDataSingleton.sectionDate
        
        var sectionAmt: Int = 0
        
        // Loop through the thankYouDataList to get the number of items for the ex-item's section date
        for item in thankYouDataList {
            let thankYouData = item as ThankYouData
            // If the item's date equals the section's date then add it
            if thankYouData.thankYouDate == sectionDate[self.delegate.indexPathSection!] {
                sectionAmt = sectionAmt + 1
            }
        }
        
        // if the ex-thankYouDate was the only one in the section, delete the section
        if sectionAmt == 1 {
            thankYouDataSingleton.sectionDate.remove(at: self.delegate.indexPathSection!)
        }
        
        // Sort the sectionDate
        thankYouDataSingleton.sectionDate.sort(by:>)
        
        // Get the index number in thankYouDataList
        var listIndexNo: Int = 0
        
        // count
        var rowCount: Int = 0
        
        // Loop through the array till the data matches and get the element at the selected row number
        for (index, item) in thankYouDataList.enumerated() {
            let thankYouData = item as ThankYouData
            
            // if thankYouDate from the item equals to the data in array, then get the index number.
            if thankYouData.thankYouDate == sectionDate[self.delegate.indexPathSection!] {
                rowCount = rowCount + 1
            }

            
            // if rowCount reachs indexPath.row, then exit the loop.
            if rowCount == self.delegate.indexPathRow! + 1 {
                listIndexNo = index
                
                break
            }
        }
        
        // Delete the element first
        thankYouDataSingleton.thankYouDataList.remove(at: listIndexNo)
        
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
        
        
        var sectionItems = [ThankYouData]()
        // Get the information which element is the thankYouData in the array
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
            if thankYouData.thankYouDate! == sectionDate[self.delegate.indexPathSection!] {
                sectionItems.append(thankYouData)
            }
        }
        let editThankYouData = sectionItems[self.delegate.indexPathRow!]
        

        
        // put the date on dateLabel
        dateLabel.text = editThankYouData.thankYouDate
        
        // put the thankYouData on the textView
        thankYouTextView.text = editThankYouData.thankYouValue
        
        // 使用するセルを登録
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "datePickerCell")

        
        
        // Expanding TextView
        thankYouTextView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 10000
        thankYouTextView.placeholder = NSLocalizedString("What are you thankful for?", comment: "")
        
        thankYouTextView.becomeFirstResponder()
        
        // String to Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let editDate = dateFormatter.date(from: editThankYouData.thankYouDate!)
        
        // Set initial date(edit date) on datePicker
        thankYouDatePicker.setDate(editDate!, animated: true)
        thankYouDatePicker.addTarget(self, action: #selector(EditThankYouDataVC.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        // tableviewの背景色指定
        self.view.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        
        // navigationbarの背景色指定
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 255/255.0, green: 248/255.0, blue: 232/255.0, alpha: 1.0)
        
        // navigationbarの文字色設定
        self.navigationController?.navigationBar.tintColor = UIColor(red: 254/255.0, green: 147/255.0, blue: 157/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 254/255.0, green: 147/255.0, blue: 157/255.0, alpha: 1.0)]
        
        
        
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
        return 3
    }

    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if (section == 2) {
            return 1
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat =  self.tableView.rowHeight
        
        if(indexPath.section == 1 && indexPath.row == 1) {
            //　DatePicker行の場合は、DatePickerの表示状態に応じて高さを返す。
            // 表示の場合は、表示で指定している高さを、非表示の場合は０を返す。
            height =  self._datePickerIsShowing ? self._DATEPICKER_CELL_HEIGHT : CGFloat(0)
        }else if (indexPath.section == 0 && indexPath.row == 1) {
            height = 20
        }
        return height
        //return UITableViewAutomaticDimension
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = deleteCell
        
        if (indexPath.section == 1 && indexPath.row == 0) {
            cell = dateCell
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            cell = datePickerCell
        } else if (indexPath.section == 0 && indexPath.row == 0) {
            cell = textViewCell
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            cell = tableViewCell
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        }
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // when a deleteCell is tapped, call delete function
        if (indexPath.section == 2 && indexPath.row == 0) {
            //　アラートコントローラーの実装
            let alertController = UIAlertController(title: NSLocalizedString("Delete Thank you", comment: ""),message: NSLocalizedString("Are you sure you want to delete this thank you?", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            //  Deleteボタンの実装
            let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: UIAlertActionStyle.destructive){ (action: UIAlertAction) in
                // Delteがクリックされた時の処理
                self.deleteThankYou()
                // Go back to the previous screen
                self.dismiss(animated: true, completion: nil)
            }
            //  Cancelボタンの実装
            let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
            
            //  ボタンに追加
            alertController.addAction(deleteAction)
            alertController.addAction(cancelButton)
            
            //  アラートの表示
            present(alertController,animated: true,completion: nil)

        }
        
        // セルを選択した時に日付があったらDatePickerの表示切り替えを行う
        if(indexPath.section == 1 && indexPath.row == 0) {
            dspDatePicker()
            thankYouTextView.endEditing(true)
        }
        // セルがタップされても残らないように設定
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    
    /*
     セクションの背景色を変更する
     */
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // 余白を作る(UIViewをセクションのビューに指定（だからxとかy指定しても意味ない）
        let view = UIView(frame: CGRect(x:0, y:0, width:20, height: 15))
        view.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        let label :UILabel = UILabel(frame: CGRect(x: 15, y: 33, width: tableView.frame.width, height: 15))
        label.textColor = UIColor(red: 90/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)
        
        // Set the sectionName
        if section == 0 {
            label.text = "Thank you"
        } else if section == 1 {
            label.text = NSLocalizedString("Date", comment: "")
        }
        
        //指定したlabelをセクションビューのサブビューに指定
        view.addSubview(label)
        return view
    }
    
    /*
     change the height of sections
     */
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
