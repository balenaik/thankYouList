//
//  ThankYouListViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 4/11/17.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import Combine
import GoogleMobileAds
import UIKit
import SkeletonView
import FloatingPanel
import SharedResources

private let skeletonedThankYouCellCount = 3
private let adUnitID: String = {
    #if DEBUG
    return "ca-app-pub-3940256099942544/2435281174"
    #else
    return "ca-app-pub-1773580597609831/6587571216"
    #endif
}()

class ThankYouListViewController: UIViewController {

    struct ListSection: Equatable {
        var yearMonthKey: String
        var items: [ThankYouData]

        var headerTitle: String {
            yearMonthKey.toDate(format: Date.listYearMonthKeyFormat)?
                .toYearMonthString() ?? ""
        }
    }

    private var estimatedRowHeights = [String : CGFloat]()
    private var cancellables = Set<AnyCancellable>()
    private var bannerCancellables = Set<AnyCancellable>()

    var viewModel: ThankYouListViewModel!

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var scrollIndicator: ListScrollIndicator!
    @IBOutlet private weak var emptyView: ThankYouEmptyView!
    @IBOutlet private weak var userIcon: UIBarButtonItem!

    @IBOutlet private weak var adView: BannerView?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        bind()
        viewModel.inputs.viewDidLoad.send()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppear.send()
        self.tableView.reloadData()
    }
}

// MARK: - Binding

private extension ThankYouListViewController {
    func bind() {
        bindOutputs()
        bindInputs()
    }

    func bindOutputs() {
        viewModel.outputs
            .reloadTableView
            .receive(on: DispatchQueue.main)
            .sink { [tableView, scrollIndicator] in
                tableView?.reloadData()
                scrollIndicator?.didUpdateContent()
            }
            .store(in: &cancellables)

        viewModel.outputs
            .showEmptyView
            .receive(on: DispatchQueue.main)
            .map { !$0 }
            .assign(to: \.isHidden, on: emptyView)
            .store(in: &cancellables)

        viewModel.outputs
            .dismissPresentedView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.presentedViewController?.dismiss(animated: true, completion: nil)
            }
            .store(in: &cancellables)

        viewModel.outputs
            .showBanner
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bannerType in
                self?.showBanner(bannerType: bannerType)
            }
            .store(in: &cancellables)

        viewModel.outputs
            .hideBanner
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.bannerCancellables.removeAll()
                self?.tableView.tableHeaderView = nil
            }
            .store(in: &cancellables)
    }

    func bindInputs() {
        userIcon.tapPublisher
            .subscribe(viewModel.inputs.userIconDidTap)
            .store(in: &cancellables)
    }
}

// MARK: - Private Methods
private extension ThankYouListViewController {
    func setupView() {
        navigationItem.title = R.string.localizable.list_navigationbar_title()
        tabBarItem.title = R.string.localizable.calendar_tabbar_title()

        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(R.nib.thankYouCell)
        tableView?.register(UINib(nibName: ListSectionHeaderView.cellIdentifier(),
                                  bundle: nil),
                            forHeaderFooterViewReuseIdentifier: ListSectionHeaderView.cellIdentifier())

        emptyView.isHidden = true
        scrollIndicator.setup(scrollView: tableView)
        scrollIndicator.delegate = self

        adView?.adUnitID = adUnitID
        adView?.delegate = self
    }

    func showBanner(bannerType: BannerType) {
        bannerCancellables.removeAll()

        let bannerView = ThankYouListBannerView.instanceFromNib()
        bannerView.bind(bannerType: bannerType)

        bannerView.actionButtonDidTap
            .map { bannerType }
            .subscribe(viewModel.inputs.bannerActionButtonDidTap)
            .store(in: &bannerCancellables)

        bannerView.closeButtonDidTap
            .map { bannerType }
            .subscribe(viewModel.inputs.bannerCloseButtonDidTap)
            .store(in: &bannerCancellables)

        tableView.tableHeaderView = bannerView
        NSLayoutConstraint.activate([
            bannerView.widthAnchor.constraint(equalTo: tableView.widthAnchor)
        ])
        tableView.layoutIfNeeded()
        // Reassigning forces UITableView's setter to re-read the header's updated frame.
        // Without this, the tableView may hold a stale frame from the initial assignment,
        // causing a gap between the banner and the content in some cases (e.g. re-showing the banner).
        tableView.tableHeaderView = tableView.tableHeaderView
    }
}
    
    
// MARK: - UITableViewDataSource
extension ThankYouListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.outputs.shouldShowSkeleton.value {
            return skeletonedThankYouCellCount
        }
        return viewModel.outputs.listSections.value.getSafely(at: section)?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.thankYouCell, for: indexPath)!
        if viewModel.outputs.shouldShowSkeleton.value {
            cell.showLoadingSkeleton()
            return cell
        }
        if let section = viewModel.outputs.listSections.value.getSafely(at: indexPath.section),
           let thankYouData = section.items.getSafely(at: indexPath.row) {
            scrollIndicator.bind(title: section.headerTitle)
            cell.bind(thankYouData: thankYouData)
        }
        cell.delegate = self
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.outputs.shouldShowSkeleton.value
        ? 1
        : viewModel.outputs.listSections.value.count
    }
}

// MARK: - UITableViewDelegate
extension ThankYouListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ListSectionHeaderView.cellIdentifier()) as! ListSectionHeaderView
        if viewModel.outputs.shouldShowSkeleton.value {
            header.showLoadingSkeleton()
            return header
        }
        if let sct = viewModel.outputs.listSections.value.getSafely(at: section) {
            header.bind(sectionString: sct.headerTitle)
        }
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ListSectionHeaderView.cellHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.outputs.shouldShowSkeleton.value {
            return tableView.estimatedRowHeight
        }
        guard let thankYouId = viewModel.outputs.listSections.value.getSafely(at: indexPath.section)?.items.getSafely(at: indexPath.row)?.id,
              let height = estimatedRowHeights[thankYouId] else {
            return tableView.estimatedRowHeight
        }
        return height
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.outputs.shouldShowSkeleton.value { return }
        cell.contentView.updateConstraintsIfNeeded()
        if let thankYouId =  viewModel.outputs.listSections.value.getSafely(at: indexPath.section)?.items.getSafely(at: indexPath.row)?.id {
            estimatedRowHeights[thankYouId] = cell.frame.size.height
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollIndicator?.scrollViewDidScroll()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollIndicator.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollIndicator.scrollViewDidEndDecelerating(scrollView)
    }
}

// MARK: - ListScrollIndicatorDelegate
extension ThankYouListViewController: ListScrollIndicatorDelegate {
    func listScrollIndicatorDidBeginDraggingMovableIcon(_ indicator: ListScrollIndicator) {
        viewModel.inputs.listScrollIndicatorDidBeginDragging.send()
    }
}

// MARK: - ThankYouCellDelegate
extension ThankYouListViewController: ThankYouCellDelegate {
    func thankYouCellDidTapThankYouView(thankYouId: String) {
        let menu = ThankYouCellTapMenu.allCases.map { $0.bottomHalfSheetMenuItem(id: thankYouId) }
        let floatingPanelViewController = FloatingPanelController.createBottomHalfSheetMenu(menu: menu)
        guard let bottomHalfSheetMenuViewController = floatingPanelViewController.contentBottomHalfSheetMenuViewController else {
            return
        }
        bottomHalfSheetMenuViewController.itemDidTap
            .subscribe(viewModel.inputs.bottomHalfSheetMenuDidTap)
            .store(in: &bottomHalfSheetMenuViewController.cancellables)

        present(floatingPanelViewController, animated: true, completion: nil)
    }
}

// MARK: - GADBannerViewDelegate
extension ThankYouListViewController: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
    }
}
