//
//  UIViewController+Setup.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/08.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func setupNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.navigationBarBg
        self.navigationController?.navigationBar.tintColor = UIColor.navigationBarText
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.navigationBarText
        ]
    }
}
