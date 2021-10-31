//
//  BottomHalfSheetMenuButton.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2021/10/29.
//  Copyright © 2021 Aika Yamada. All rights reserved.
//

import UIKit

struct BottomHalfSheetMenuItem {
    let title: String
    let image: UIImage?
    let rawValue: Int?
}

class BottomHalfSheetMenuItemView: UIControl {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var item: BottomHalfSheetMenuItem?

    class func instanceFromNib() -> BottomHalfSheetMenuItemView {
        let view = R.nib.bottomHalfSheetMenuItemView.firstView(owner: nil)!
        return view
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .highlight : .white
        }
    }

    func bind(item: BottomHalfSheetMenuItem) {
        self.item = item
        imageView.image = item.image
        titleLabel.text = item.title
    }
}
