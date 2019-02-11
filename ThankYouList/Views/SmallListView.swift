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
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = Bundle.main.loadNibNamed("SmallListView", owner: self, options: nil)?.first as! UIView
        self.addSubview(view)
        self.view = view
    }
    
    // MARK: - View Lifecycles
    override func layoutSubviews() {
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 10
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
        tableView.register(UINib(nibName: ListSectionHeaderView.cellIdentifier(),
                                  bundle: nil),
                            forHeaderFooterViewReuseIdentifier: ListSectionHeaderView.cellIdentifier())
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
}
