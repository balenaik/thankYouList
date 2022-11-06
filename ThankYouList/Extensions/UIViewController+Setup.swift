//
//  UIViewController+Setup.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/08.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import UIKit

private let navigationBarTitleFontSize = CGFloat(19)

extension UIViewController {
    func setupNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .text
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.text,
            NSAttributedString.Key.font: UIFont.boldAvenir(ofSize: navigationBarTitleFontSize)
        ]
    }
}
