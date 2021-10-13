//
//  ThankYouCell.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/01/27.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit
import SkeletonView

private let thankYouViewCornerRadius = CGFloat(8)
private let thankYouViewShadowColor = UIColor.black.withAlphaComponent(0.26)
private let thankYouViewShadowOpacity = Float(0.3)
private let thankYouViewShadowOffset = CGSize(width: 0, height: 5)

private var buttonAnimationDuration = 0.2
private var scaleDownRatio = CGFloat(0.97)

protocol ThankYouCellDelegate: class {
    func thankYouCellDidTapThankYouView()
}

class ThankYouCell: UITableViewCell {
    
    private var thankYouData: ThankYouData?
    @IBOutlet private weak var thankYouView: UIView!
    @IBOutlet private weak var thankYouViewButton: UIButton!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var dayMonthStackView: UIStackView!

    weak var delegate: ThankYouCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        thankYouView.layer.cornerRadius = thankYouViewCornerRadius
        thankYouView.layer.shadowColor = thankYouViewShadowColor.cgColor
        thankYouView.layer.shadowOpacity = thankYouViewShadowOpacity
        thankYouView.layer.shadowOffset = thankYouViewShadowOffset
        contentLabel.isSkeletonable = true
        dayMonthStackView.isSkeletonable = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentLabel.hideSkeleton()
        dayMonthStackView.hideSkeleton()
    }
    
    @objc class func cellIdentifier() -> String {
        return String(describing: self)
    }
    
    func bind(thankYouData: ThankYouData) {
        self.thankYouData = thankYouData
        contentLabel.text = thankYouData.value
        dayLabel.text = thankYouData.date.toDayString()
        monthLabel.text = thankYouData.date.toMonthEnglish3lettersString()
    }

    func showLoadingSkeleton() {
        contentLabel.showSkeleton(transition: .crossDissolve(ViewConst.skeletonViewFadeTime))
        dayMonthStackView.showSkeleton(transition: .crossDissolve(ViewConst.skeletonViewFadeTime))
    }
}

// MARK: - Button Animation
private extension ThankYouCell {
    @IBAction func thankYouViewButtonTouchUpInside(_ sender: Any) {
        restoreOriginalScaleAnimation()
        delegate?.thankYouCellDidTapThankYouView()
    }

    @IBAction func thankYouViewButtonTouchDown(_ sender: Any) {
        scaleDownAnimation()
    }

    @IBAction func thankYouViewButtonTouchDragInside(_ sender: Any) {
        restoreOriginalScaleAnimation()
    }

    func scaleDownAnimation() {
        UIView.animate(withDuration: buttonAnimationDuration) {
            self.thankYouView.transform = CGAffineTransform(scaleX: scaleDownRatio, y: scaleDownRatio)
        }
    }

    func restoreOriginalScaleAnimation() {
        UIView.animate(withDuration: buttonAnimationDuration) {
            self.thankYouView.transform = CGAffineTransform.identity
        }
    }
}
