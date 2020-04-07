//
//  ListScrollIndicator.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/08/12.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

private let iconHeight = CGFloat(40)
private let iconWidth = CGFloat(40)

private let titleViewSetHiddenDuration = 0.4
private let titleViewSetHiddenDelay = 0.4
private let titleViewUnsetHiddenDuration = 0.2

struct ListScrollIndicatorAttributes {
    var scrollView: UIScrollView
}

class ListScrollIndicator: UIView {
    private let movableIcon: ListScrollIndicatorMovableIcon
    private let titleView: ListScrollIndicatorTitleView
    private var movableIconTopAnchor: NSLayoutConstraint?
    private var scrollView: UIScrollView?

    /// Set scrollView offset y when movableIcon start being dragged and nil when ended
    private var originalOffsetY: CGFloat?

    required init?(coder aDecoder: NSCoder) {
        let movableIcon = ListScrollIndicatorMovableIcon.instanceFromNib()
        self.movableIcon = movableIcon
        let titleView = ListScrollIndicatorTitleView.instanceFromNib()
        self.titleView = titleView
        super.init(coder: aDecoder)

        self.addSubview(movableIcon)
        self.addSubview(titleView)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragMovableIcon(_:)))
        movableIcon.addGestureRecognizer(panGesture)

        self.backgroundColor = UIColor.clear
        titleView.isHidden = true

        setupConstraints()
    }

    private func setupConstraints() {
        movableIcon.translatesAutoresizingMaskIntoConstraints = false
        movableIconTopAnchor = movableIcon.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        movableIconTopAnchor?.isActive = true
        movableIcon.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        movableIcon.heightAnchor.constraint(equalToConstant: iconHeight).isActive = true
        movableIcon.widthAnchor.constraint(equalToConstant: iconWidth).isActive = true

        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.centerYAnchor.constraint(equalTo: movableIcon.centerYAnchor).isActive = true
        titleView.trailingAnchor.constraint(equalTo: movableIcon.leadingAnchor, constant: -20).isActive = true
        titleView.backgroundColor = UIColor.green
    }
}

// MARK: - public
extension ListScrollIndicator {
    /// Call on viewDidLoad() method
    /// - parameter scrollView: ScrollView to be set this indicator
    func setup(scrollView: UIScrollView) {
        self.scrollView = scrollView
        scrollView.showsVerticalScrollIndicator = false
    }

    /// Call when scrollView contents has set
    func updatedContent() {
        updateMovableIconHiddenStatus()
    }

    /// Call on scrollViewDidScroll() method
    func scrollViewDidScroll() {
        updateMovableIconHiddenStatus()
        guard let scrollView = scrollView, movableIcon.isHidden == false else { return }
        let contentSizeHeight = scrollView.contentSize.height
        let indicatorHeight = self.frame.size.height - iconHeight / 2 // adjusting icon's top anchor constraint
        movableIconTopAnchor?.constant = scrollView.contentOffset.y / contentSizeHeight * indicatorHeight
        updateTitleViewHiddenStatus(isHidden: false)
    }

    /// Call on scrollViewDidEndDragging method
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // When declareted, scrollViewDidEndDecelarating will be called.
        if !decelerate {
            updateTitleViewHiddenStatus(isHidden: true)
        }
    }

    /// Call on scrollViewDidEndDecelerating() method
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateTitleViewHiddenStatus(isHidden: true)
    }

    /// Call on whenever you want to set a title (e.g. cellForRowAt(), viewForHeaderInSection() etc.)
    func bind(title: String) {
        titleView.bind(title: title)
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
            let indicatorHeight = self.frame.size.height - iconHeight / 2 // adjusting icon's top anchor constraint
            let maxY = contentSizeHeight - scrollView.frame.size.height
            var newY = originalOffsetY + ((movedY / indicatorHeight) * contentSizeHeight)
            if newY < 0 {
                newY = 0
            } else if newY > maxY {
                newY = maxY
            }
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x,
                                                y: newY),
                                        animated: false)
        case .ended:
            originalOffsetY = nil
            updateTitleViewHiddenStatus(isHidden: true)
        default: break
        }
    }

    private func updateMovableIconHiddenStatus() {
        guard let scrollView = scrollView else { return }
        // If the scrollView is not scrollable, movableIcon set hidden
        movableIcon.isHidden = scrollView.contentSize.height <= scrollView.frame.size.height ?
            true : false
    }

    private func updateTitleViewHiddenStatus(isHidden: Bool) {
        if isHidden {
            UIView.animate(withDuration: titleViewSetHiddenDuration, delay: titleViewSetHiddenDelay, animations: {
                self.titleView.alpha = 0
            }, completion:  {
                (value: Bool) in
                self.titleView.isHidden = true
            })
        } else {
            titleView.isHidden = false
            UIView.animate(withDuration: titleViewUnsetHiddenDuration, animations: {
                self.titleView.alpha = 1
            }, completion:  nil)
        }
    }
}
