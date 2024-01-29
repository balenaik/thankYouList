//
//  ThankYouEmptyView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/08/25.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class ThankYouEmptyView: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = R.nib.emptyView(withOwner: self)!
        self.addSubview(view)
        setupConstraints(view: view)
        setupLabel()
    }
}

private extension ThankYouEmptyView {
    func setupConstraints(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }

    func setupLabel() {
        titleLabel.text = R.string.localizable.thank_you_list_empty_view_title()
        descriptionLabel.text = R.string.localizable.thank_you_list_empty_view_description()
    }
}
