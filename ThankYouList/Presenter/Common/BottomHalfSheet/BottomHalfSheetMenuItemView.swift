//
//  BottomHalfSheetMenuButton.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2021/10/29.
//  Copyright © 2021 Aika Yamada. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

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
    private var cancellables = Set<AnyCancellable>()

    // Public Publisher
    let viewDidTap = PassthroughSubject<BottomHalfSheetMenuItem, Never>()

    class func instanceFromNib() -> BottomHalfSheetMenuItemView {
        let view = R.nib.bottomHalfSheetMenuItemView.firstView(withOwner: nil)!
        return view
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        controlEventPublisher(for: .touchUpInside)
            .compactMap { [weak self] in
                self?.item
            }
            .subscribe(viewDidTap)
            .store(in: &cancellables)
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
