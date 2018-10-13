//
//  EditThankYouDataVC.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2017/06/24.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class EditThankYouDataVC: UITableViewController, UITextViewDelegate {
    
    // MARK: - Properties
    private var delegate = UIApplication.shared.delegate
    private var _datePickerIsShowing = false
    private var editingThankYouData: ThankYouData?
    private var db = Firestore.firestore()
    
    // MARK: - IBOutlets
    @IBOutlet weak var thankYouDatePicker: UIDatePicker!
    @IBOutlet weak var editThankYou: UINavigationItem!
    @IBOutlet weak var thankYouTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textViewCell: UITableViewCell!
    @IBOutlet weak var dateCell: UITableViewCell!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var tableViewCell: UITableViewCell!
    @IBOutlet weak var deleteCell: UITableViewCell!

    
    
    // MARK: - IBActions
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func edit(_ sender: Any) {
        if (thankYouTextView.text.isEqual("") || thankYouTextView.text.isEmpty) {
            return
        }
        guard let dateLabelText = dateLabel.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Not login? error")
            return
        }
        let uid16string = String(uid.prefix(16))
        let encryptedValue = Crypto().encryptString(plainText: thankYouTextView.text, key: uid16string)
        let editedThankYouData = ThankYouData(id: "", value: "", encryptedValue: encryptedValue, date: dateLabelText, createTime: Date())
        editThankYou(editThankYouData: editedThankYouData, uid: uid)
    }
    
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let editingThankYouData = editingThankYouData else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "datePickerCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 10000
        
        dateLabel.text = editingThankYouData.date
        
        thankYouTextView.delegate = self
        thankYouTextView.text = editingThankYouData.value
        thankYouTextView.placeholder = NSLocalizedString("What are you thankful for?", comment: "")
        thankYouTextView.becomeFirstResponder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        if let editingDate = dateFormatter.date(from: editingThankYouData.date) {
            thankYouDatePicker.setDate(editingDate, animated: true)
        }
        thankYouDatePicker.addTarget(self, action: #selector(EditThankYouDataVC.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
        // tableviewの背景色指定
        self.view.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = TYLColor.navigationBarBgColor
        self.navigationController?.navigationBar.tintColor = TYLColor.navigationBarTextColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(red: 254/255.0, green: 147/255.0, blue: 157/255.0, alpha: 1.0)]
    }

    
    
    // MARK: - Private Methods
    private func editThankYou(editThankYouData: ThankYouData, uid: String) {
        guard let editingThankYouData = editingThankYouData else { return }
        db.collection("users").document(uid).collection("thankYouList").document(editingThankYouData.id).updateData(editThankYouData.dictionary) { [weak self] error in
            guard let weakSelf = self else { return }
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
                let alert = UIAlertController(title: nil, message: NSLocalizedString("Failed to edit", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                weakSelf.present(alert, animated: true, completion: nil)
                return
            }
            weakSelf.dismiss(animated: true, completion: nil)
        }
    }
    
    private func deleteThankYou() {
        guard let editingThankYouData = editingThankYouData else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Not login? error")
            return
        }
        db.collection("users").document(uid).collection("thankYouList").document(editingThankYouData.id).delete(completion: { [weak self] error in
            guard let weakSelf = self else { return }
            if let error = error {
                let alert = UIAlertController(title: nil, message: NSLocalizedString("Failed to delete", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                weakSelf.present(alert, animated: true, completion: nil)
            }
            weakSelf.dismiss(animated: true, completion: nil)
        })
    }
    
        private func getSectionItemCount(thankYouDateString: String) -> Int {
            var sectionItems = [ThankYouData]()
            let thankYouDataSingleton = GlobalThankYouData.sharedInstance
            let thankYouDataList: [ThankYouData] = thankYouDataSingleton.thankYouDataList
            sectionItems = thankYouDataList.filter({$0.date == thankYouDateString})
            return sectionItems.count
        }
//
//        // Get the singleton
//        let thankYouDataSingleton: GlobalThankYouData = GlobalThankYouData.sharedInstance
//        // ThankYouを格納した配列
//        let thankYouDataList: [ThankYouDataUD] = thankYouDataSingleton.thankYouDataUDList
//        // Sectionで利用する配列
//        var sectionDate: [String] = thankYouDataSingleton.sectionDate
//
//        var sectionAmt: Int = 0
//
//        // Loop through the thankYouDataList to get the number of items for the ex-item's section date
//        for item in thankYouDataList {
//            let thankYouData = item as ThankYouDataUD
//            // If the item's date equals the section's date then add it
//            if thankYouData.thankYouDate == sectionDate[self.delegate.indexPathSection!] {
//                sectionAmt = sectionAmt + 1
//            }
//        }
//
//        // if the ex-thankYouDate was the only one in the section, delete the section
//        if sectionAmt == 1 {
//            thankYouDataSingleton.sectionDate.remove(at: self.delegate.indexPathSection!)
//        }
//
//        // Sort the sectionDate
//        thankYouDataSingleton.sectionDate.sort(by:>)
//
//        // Get the index number in thankYouDataList
//        var listIndexNo: Int = 0
//
//        // count
//        var rowCount: Int = 0
//
//        // Loop through the array till the data matches and get the element at the selected row number
//        for (index, item) in thankYouDataList.enumerated() {
//            let thankYouData = item as ThankYouDataUD
//
//            // if thankYouDate from the item equals to the data in array, then get the index number.
//            if thankYouData.thankYouDate == sectionDate[self.delegate.indexPathSection!] {
//                rowCount = rowCount + 1
//            }
//
//
//            // if rowCount reachs indexPath.row, then exit the loop.
//            if rowCount == self.delegate.indexPathRow! + 1 {
//                listIndexNo = index
//
//                break
//            }
//        }
//
//        // Delete the element first
//        thankYouDataSingleton.thankYouDataList.remove(at: listIndexNo)
//


    
    
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
    
    


    @objc func datePickerValueChanged (thankYouDatePicker: UIDatePicker) {
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
            height =  self._datePickerIsShowing ? ConstStruct._DATEPICKER_CELL_HEIGHT : CGFloat(0)
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
            cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            cell = tableViewCell
            cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // when a deleteCell is tapped, call delete function
        if (indexPath.section == 2 && indexPath.row == 0) {
            //　アラートコントローラーの実装
            let alertController = UIAlertController(title: NSLocalizedString("Delete Thank you", comment: ""),message: NSLocalizedString("Are you sure you want to delete this thank you?", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            //  Deleteボタンの実装
            let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: UIAlertAction.Style.destructive){ (action: UIAlertAction) in
                // Delteがクリックされた時の処理
                self.deleteThankYou()
            }
            //  Cancelボタンの実装
            let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
            
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


extension EditThankYouDataVC {
    class func createViewController(thankYouData: ThankYouData?) -> EditThankYouDataVC {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editThankYouDataVC") as! EditThankYouDataVC
        vc.editingThankYouData = thankYouData
        return vc
    }
}
