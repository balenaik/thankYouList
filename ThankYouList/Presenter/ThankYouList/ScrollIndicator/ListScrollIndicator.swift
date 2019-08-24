//
//  ListScrollIndicator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/08/12.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

class ListScrollIndicator: UIView {
    private let movableIcon: ListScrollIndicatorMovableIcon
    private let dateView: ListScrollIndicatorDateView
    private var movableIconTopAnchor: NSLayoutConstraint?

    required init?(coder aDecoder: NSCoder) {
        let movableIcon = ListScrollIndicatorMovableIcon.instanceFromNib()
        self.movableIcon = movableIcon
        let dateView = ListScrollIndicatorDateView.instanceFromNib()
        self.dateView = dateView
        super.init(coder: aDecoder)

        self.addSubview(movableIcon)
        self.addSubview(dateView)
        movableIcon.translatesAutoresizingMaskIntoConstraints = false
        movableIconTopAnchor = movableIcon.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        movableIconTopAnchor?.isActive = true
        movableIcon.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        movableIcon.heightAnchor.constraint(equalToConstant: 50).isActive = true
        movableIcon.widthAnchor.constraint(equalToConstant: 50).isActive = true

        dateView.translatesAutoresizingMaskIntoConstraints = false
        dateView.centerYAnchor.constraint(equalTo: movableIcon.centerYAnchor).isActive = true
        dateView.trailingAnchor.constraint(equalTo: movableIcon.leadingAnchor, constant: -20).isActive = true
        dateView.backgroundColor = UIColor.green
    }
}

// MARK: - public
extension ListScrollIndicator {
    func updateMovableIcon(scrollView: UIScrollView) {
        let contentSizeHeight = scrollView.contentSize.height == 0 ? 1 : scrollView.contentSize.height
        movableIconTopAnchor?.constant = scrollView.contentOffset.y / contentSizeHeight * self.frame.size.height
    }
}
