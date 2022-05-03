//
//  EmptyView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/08/25.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class EmptyView: UIView {
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = R.nib.emptyView(owner: self)!
        self.addSubview(view)
        setupConstraints(view: view)
    }
}

private extension EmptyView {
    func setupConstraints(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }
}
