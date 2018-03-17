//
//  ContainerVC.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/03/17.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import Foundation
import SlideMenuControllerSwift

class ContainerVC: SlideMenuController {
    override func awakeFromNib() {
        if let leftMenuVC = self.storyboard?.instantiateViewController(withIdentifier: "LeftMenuVC") {
            self.leftViewController = leftMenuVC
        }
        super.awakeFromNib()
    }
}
