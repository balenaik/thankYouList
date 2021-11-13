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
    let id: String?
}

protocol BottomHalfSheetMenuItemViewDelegate: class {
    func bottomHalfSheetMenuItemViewDidTap(item: BottomHalfSheetMenuItem)
}

class BottomHalfSheetMenuItemView: UIControl {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var item: BottomHalfSheetMenuItem?

    weak var delegate: BottomHalfSheetMenuItemViewDelegate?

    class func instanceFromNib() -> BottomHalfSheetMenuItemView {
        let view = R.nib.bottomHalfSheetMenuItemView.firstView(owner: nil)!
        return view
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action: #selector(didTapView), for: .touchUpInside)
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

// MARK: - Private
private extension BottomHalfSheetMenuItemView {
    @objc func didTapView() {
        guard let item = item else { return }
        delegate?.bottomHalfSheetMenuItemViewDidTap(item: item)
    }
}
