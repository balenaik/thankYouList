//
//  SmallListView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/02/10.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import UIKit

class SmallListView: UIView {
    
    // MARK: - Properties
    var view: UIView!
    var isFullScreen = false {
        didSet {
            if isFullScreen {
                tableView.isScrollEnabled = true
                setNeedsLayout()
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = Bundle.main.loadNibNamed("SmallListView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        self.view = view
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
        tableView.register(UINib(nibName: ThankYouCell.cellIdentifier(),
                                  bundle: nil),
                            forCellReuseIdentifier: ThankYouCell.cellIdentifier())
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
}
