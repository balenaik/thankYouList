//
//  UIImage+FromUIColor.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2021/01/07.
//  Copyright © 2021 Aika Yamada. All rights reserved.
//

import UIKit

extension UIImage {
    static func createImage(color: UIColor, width: Double = 1, height: Double = 1) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
