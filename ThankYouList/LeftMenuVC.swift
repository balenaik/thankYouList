//
//  LeftMenuVC.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/03/17.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class LeftMenuVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
}

extension LeftMenuVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
        return cell
    }
    
    
}

extension LeftMenuVC: UITableViewDelegate {
    
}
