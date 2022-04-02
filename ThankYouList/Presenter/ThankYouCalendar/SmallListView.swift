//
//  SmallListView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/02/10.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

private let shadowColor = UIColor.black26
private let shadowOpacity = Float(0.2)
private let shadowOffset = CGSize(width: 0, height: -0.1)
private let shadowRadius = CGFloat(3)

protocol SmallListViewDelegate: class {
    func smallListViewBecomeFullScreen(_ view: SmallListView)
}

class SmallListView: UIView {
    
    // MARK: - Properties
    var view: UIView!
    var isFullScreen = false {
        didSet {
            if isFullScreen {
                delegate?.smallListViewBecomeFullScreen(self)
                tableView.isScrollEnabled = true
                setNeedsLayout()
            }
        }
    }

    weak var delegate: SmallListViewDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = R.nib.smallListView(owner: self)!
        self.addSubview(view)
        setupConstraints(view: view)
        self.view = view
    }

    private func setupConstraints(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }
    
    // MARK: - View Lifecycles
    override func layoutSubviews() {
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let cornerRadius: CGFloat = isFullScreen ? 0 : 10
        headerView.layer.cornerRadius = cornerRadius
        view.layer.cornerRadius = cornerRadius
        view.dropShadow()
        super.layoutSubviews()
    }
}

// MARK: - Public Methods
extension SmallListView {
    func setupTableView(_ viewController: UIViewController) {
        if let dataSource = viewController as? UITableViewDataSource {
            tableView.dataSource = dataSource
        }
        if let delegate = viewController as? UITableViewDelegate {
            tableView.delegate = delegate
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(R.nib.thankYouCell)
    }
    
    func setDateLabel(dateString: String) {
        dateLabel.text = dateString
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func setTableViewScrollingSetting(isEnabled: Bool) {
        tableView.isScrollEnabled = isEnabled
    }

    func getTableViewContentOffset() -> CGPoint {
        return tableView.contentOffset
    }
    
    func setTableViewOffsetZero() {
        tableView.contentOffset = CGPoint(x: 0, y: 0)
    }
}

// MARK: - Private methods
private extension SmallListView {
    func dropShadow() {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
    }
}
