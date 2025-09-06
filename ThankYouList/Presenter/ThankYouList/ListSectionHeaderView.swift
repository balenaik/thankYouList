//
//  ListSectionHeaderView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/02/02.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation
import SharedResources
import UIKit

private let sectionLabelSkeletonColor = UIColor.white

class ListSectionHeaderView: UITableViewHeaderFooterView {

    static let cellHeight = CGFloat(50)

    @IBOutlet private weak var sectionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        sectionLabel.isSkeletonable = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sectionLabel.hideSkeleton()
    }
}

// MARK: - Internal Methods
extension ListSectionHeaderView {

    @objc class func cellIdentifier() -> String {
        return String(describing: self)
    }
    
    func bind(sectionString: String) {
        sectionLabel.text = sectionString
    }

    func showLoadingSkeleton() {
        sectionLabel.showSkeleton(usingColor: sectionLabelSkeletonColor,
                                  transition: .crossDissolve(ViewConst.skeletonViewFadeTime))
    }
}
