//
//  ThankYouListViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2026/01/20.
//  Copyright © 2026 Aika Yamada. All rights reserved.
//

import Combine
import CombineSchedulers
import Foundation

protocol ThankYouListRouter: Router {
    func presentMyPage()
    func presentEditThankYou(thankYouId: String)
    func presentPositiveStatementList()
}

class ThankYouListViewModel: ObservableObject {

    let inputs = Inputs()
    let outputs = Outputs()

    private var cancellables = Set<AnyCancellable>()
    private let userRepository: UserRepository
    private let thankYouRepository: ThankYouRepository
    private var userDefaultsDataStore: UserDefaultsDataStore
    private let analyticsManager: AnalyticsManager
    private let notificationCenterProtocol: NotificationCenterProtocol
    private let router: ThankYouListRouter?
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(
        userRepository: UserRepository,
        thankYouRepository: ThankYouRepository,
        userDefaultsDataStore: UserDefaultsDataStore,
        analyticsManager: AnalyticsManager,
        notificationCenterProtocol: NotificationCenterProtocol,
        router: ThankYouListRouter,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.userRepository = userRepository
        self.thankYouRepository = thankYouRepository
        self.userDefaultsDataStore = userDefaultsDataStore
        self.analyticsManager = analyticsManager
        self.notificationCenterProtocol = notificationCenterProtocol
        self.router = router
        self.scheduler = scheduler
        bind()
    }
}

private extension ThankYouListViewModel {
    func bind() {
        bindCardTapAction()
        bindBanner()

        inputs.viewDidLoad
            .flatMap { [userRepository] in
                userRepository.getUserProfile().map(\.id)
            }
            .flatMap { [thankYouRepository] userId in
                thankYouRepository.subscribeThankYouList(userId: userId)
            }
            .catch { error in Just(.error(error)) }
            .scan([ThankYouListViewController.ListSection]()) { [weak self] list, result in
                var newList = list
                switch result {
                case .initial:
                    break
                case .added(let thankYouData):
                    self?.addThankYouToList(thankYouData: thankYouData, to: &newList)
                case .updated(let oldThankYou, let newThankYou):
                    self?.removeThankYouFromList(thankYouData: oldThankYou, from: &newList)
                    self?.addThankYouToList(thankYouData: newThankYou, to: &newList)
                case .removed(let removedThankYou):
                    self?.removeThankYouFromList(thankYouData: removedThankYou, from: &newList)
                case .error:
                    self?.router?.presentAlert(
                        title: R.string.localizable.thank_you_list_load_error_title(),
                        message: R.string.localizable.thank_you_list_load_error_message()
                    )
                }
                return newList
            }
            .removeDuplicates()
            .sendEvent(false, to: outputs.shouldShowSkeleton)
            .subscribe(outputs.listSections)
            .store(in: &cancellables)

        outputs.listSections
            .dropFirst()
            .removeDuplicates(by: { $0 == $1 })
            .map { _ in }
            .debounce(for: .milliseconds(500), scheduler: scheduler)
            .handleEvents(receiveOutput: { [notificationCenterProtocol] in
                notificationCenterProtocol.post(Notification(
                    name: Notification.Name(rawValue: NotificationConst.THANK_YOU_LIST_UPDATED)
                ))
            })
            .subscribe(outputs.reloadTableView)
            .store(in: &cancellables)

        outputs.listSections
            .dropFirst()
            .map(\.isEmpty)
            .removeDuplicates()
            .subscribe(outputs.showEmptyView)
            .store(in: &cancellables)

        inputs.userIconDidTap
            .receive(on: scheduler)
            .sink { [router] in
                router?.presentMyPage()
            }
            .store(in: &cancellables)

        inputs.listScrollIndicatorDidBeginDragging
            .sink { [analyticsManager] in
                analyticsManager.logEvent(
                    eventName: AnalyticsEventConst.startDraggingListScrollIndicatorMovableIcon
                )
            }
            .store(in: &cancellables)
    }

    func bindCardTapAction() {
        let didTapMenu = inputs.bottomHalfSheetMenuDidTap
            .compactMap { menuItem -> (menu: ThankYouCellTapMenu, thankYouId: String)? in
                guard let itemRawValue = menuItem.rawValue,
                      let cellMenu = ThankYouCellTapMenu(rawValue: itemRawValue),
                      let thankYouId = menuItem.id else {
                    return nil
                }
                return (menu: cellMenu, thankYouId: thankYouId)
            }
            .sendEvent((), to: outputs.dismissPresentedView)
            .share()

        didTapMenu
            .filter { $0.menu == .edit }
            .receive(on: scheduler)
            .sink { [router] in
                router?.presentEditThankYou(thankYouId: $0.thankYouId)
            }
            .store(in: &cancellables)

        let deleteAction = PassthroughSubject<String, Never>()

        didTapMenu
            .filter { $0.menu == .delete }
            .receive(on: scheduler)
            .sink { [router] menuItem in
                let deleteAction = AlertAction(title: R.string.localizable.delete(),
                                               style: .destructive) {
                    deleteAction.send(menuItem.thankYouId)
                }
                let cancelAction = AlertAction(title: R.string.localizable.cancel(),
                                               style: .cancel)
                router?.presentAlert(
                    title: R.string.localizable.deleteThankYou(),
                    message: R.string.localizable.areYouSureYouWantToDeleteThisThankYou(),
                    actions: [deleteAction, cancelAction]
                )
            }
            .store(in: &cancellables)

        let deleteResult = deleteAction
            .flatMap { [userRepository, thankYouRepository] thankYouId in
                userRepository.getUserProfile()
                    .flatMap { [thankYouRepository] profile in
                        let deletingThankYou = thankYouRepository.loadThankYou(thankYouId: thankYouId)
                        return thankYouRepository.deleteThankYou(
                            thankYouId: thankYouId,
                            userId: profile.id)
                        .map { _ in deletingThankYou }
                    }
                    .asResult()
            }
            .eraseToAnyPublisher()
            .share()

        deleteResult
            .values()
            .sink { [analyticsManager] deletedThankYou in
                analyticsManager.logEvent(
                    eventName: AnalyticsEventConst.deleteThankYou,
                    targetDate: deletedThankYou?.date
                )
            }
            .store(in: &cancellables)

        deleteResult
            .errors()
            .receive(on: scheduler)
            .sink { [router] _ in
                router?.presentAlert(title: nil,
                                     message: R.string.localizable.failedToDelete())
            }
            .store(in: &cancellables)
    }

    func bindBanner() {
        let shouldShowPositiveStatementBanner = Publishers
            .Merge(
                inputs.viewWillAppear,
                notificationCenterProtocol.publisher(for: UserDefaults.didChangeNotification).map { _ in }
            )
            .map { [userDefaultsDataStore] in
                !userDefaultsDataStore.hasSeenPositiveStatementOnboarding
                && !userDefaultsDataStore.hasDismissedPositiveStatementBannerOnThankYouList
            }
            .removeDuplicates()
            .share()

        shouldShowPositiveStatementBanner
            .filter { $0 }
            .handleEvents(receiveOutput: { [analyticsManager] _ in
                analyticsManager.logEvent(eventName: AnalyticsEventConst.showPositiveStatementBanner)
            })
            .map { _ in BannerType.positiveStatementPromotion }
            .subscribe(outputs.showBanner)
            .store(in: &cancellables)

        shouldShowPositiveStatementBanner
            .filter { !$0 }
            .map { _ in }
            .subscribe(outputs.hideBanner)
            .store(in: &cancellables)
    }
}

private extension ThankYouListViewModel {
    func addThankYouToList(
        thankYouData: ThankYouData,
        to listSections: inout [ThankYouListViewController.ListSection]
    ) {
        let dateKey = thankYouData.date.toString(format: Date.listYearMonthKeyFormat)
        if let sectionIndex = listSections.firstIndex(where: { $0.yearMonthKey == dateKey }) {
            let sectionItems = listSections[sectionIndex].items
            let insertIndex = sectionItems.firstIndex(where: { $0.date < thankYouData.date }) ?? sectionItems.count
            listSections[sectionIndex].items.insert(thankYouData, at: insertIndex)
        } else {
            let insertIndex = listSections.firstIndex(where: { $0.yearMonthKey < dateKey })
            ?? listSections.count
            listSections.insert(.init(yearMonthKey: dateKey, items: [thankYouData]), at: insertIndex)
        }
    }

    func removeThankYouFromList(
        thankYouData: ThankYouData,
        from listSections: inout [ThankYouListViewController.ListSection]
    ) {
        let dateKey = thankYouData.date.toString(format: Date.listYearMonthKeyFormat)
        guard let sectionIndex = listSections.firstIndex(where: { $0.yearMonthKey == dateKey }),
              let thankYouIndex = listSections[sectionIndex].items.firstIndex(where: { $0.id == thankYouData.id }) else {
            return
        }
        listSections[sectionIndex].items.remove(at: thankYouIndex)
        if listSections[sectionIndex].items.isEmpty {
            listSections.remove(at: sectionIndex)
        }
    }
}

extension ThankYouListViewModel {
    class Inputs {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let viewWillAppear = PassthroughSubject<Void, Never>()
        let userIconDidTap = PassthroughSubject<Void, Never>()
        let bottomHalfSheetMenuDidTap = PassthroughSubject<BottomHalfSheetMenuItem, Never>()
        let listScrollIndicatorDidBeginDragging = PassthroughSubject<Void, Never>()
        let bannerActionButtonDidTap = PassthroughSubject<BannerType, Never>()
        let bannerCloseButtonDidTap = PassthroughSubject<BannerType, Never>()
    }

    class Outputs {
        let listSections = CurrentValueSubject<[ThankYouListViewController.ListSection], Never>([])
        let shouldShowSkeleton = CurrentValueSubject<Bool, Never>(true)
        let reloadTableView = PassthroughSubject<Void, Never>()
        let showEmptyView = CurrentValueSubject<Bool, Never>(false)
        let dismissPresentedView = PassthroughSubject<Void, Never>()
        let showBanner = PassthroughSubject<BannerType, Never>()
        let hideBanner = PassthroughSubject<Void, Never>()
    }
}
