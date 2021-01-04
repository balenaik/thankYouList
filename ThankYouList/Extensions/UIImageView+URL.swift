//
//  UIImageView+URL.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/23.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    /// Set Image Url
    /// - Parameters:
    ///   * url: URL
    func setImage(from url: URL?) {
        self.sd_setImage(with: url, completed: { (_, error, _, _) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
    }
}
