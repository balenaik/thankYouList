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
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // put today on dateLabel
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let nowString = formatter.string(from: now as Date)
        dateLabel.text = nowString
        
        
        
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
        return UITableViewAutomaticDimension
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
