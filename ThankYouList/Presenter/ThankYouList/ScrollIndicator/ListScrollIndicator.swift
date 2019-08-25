//
//  ListScrollIndicator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/08/12.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

protocol ListScrollIndicatorDelegate: class {
}

struct ListScrollIndicatorAttributes {
    var scrollView: UIScrollView
}

class ListScrollIndicator: UIView {
    private let movableIcon: ListScrollIndicatorMovableIcon
    private let dateView: ListScrollIndicatorDateView
    private var movableIconTopAnchor: NSLayoutConstraint?

    private var attributes: ListScrollIndicatorAttributes?
    private var scrollView: UIScrollView? {
        return attributes?.scrollView
    }

    /// Set scrollView offset y when movableIcon start being dragged and nil when ended
    private var originalOffsetY: CGFloat?

    weak var delegate: ListScrollIndicatorDelegate?

    required init?(coder aDecoder: NSCoder) {
        let movableIcon = ListScrollIndicatorMovableIcon.instanceFromNib()
        self.movableIcon = movableIcon
        let dateView = ListScrollIndicatorDateView.instanceFromNib()
        self.dateView = dateView
        super.init(coder: aDecoder)

        self.addSubview(movableIcon)
        self.addSubview(dateView)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragMovableIcon(_:)))
        movableIcon.addGestureRecognizer(panGesture)
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
    func setup(attributes: ListScrollIndicatorAttributes, delegate: ListScrollIndicatorDelegate?) {
        self.attributes = attributes
        self.delegate = delegate
    }

    func updateMovableIcon(scrollView: UIScrollView) {
        let contentSizeHeight = scrollView.contentSize.height == 0 ? 1 : scrollView.contentSize.height
        movableIconTopAnchor?.constant = scrollView.contentOffset.y / contentSizeHeight * self.frame.size.height
    }
}

// MARK: - private
extension ListScrollIndicator {
    @objc private func dragMovableIcon(_ sender: UIPanGestureRecognizer) {
        guard let scrollView = scrollView else { return }
        switch sender.state {
        case .began:
            originalOffsetY = scrollView.contentOffset.y
        case .changed:
            guard let originalOffsetY = originalOffsetY else { return }
            let movedY = sender.translation(in: self).y
            let contentSizeHeight = scrollView.contentSize.height == 0 ? 1 : scrollView.contentSize.height
            let indicatorHeight = self.frame.size.height
            let newY = (movedY / indicatorHeight) * contentSizeHeight
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x,
                                                y: originalOffsetY + newY),
                                        animated: false)
        case .ended:
            originalOffsetY = nil
        default: break
        }
    }
}
