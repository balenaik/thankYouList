//
//  ThankYouListViewModelTests.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2026/01/21.
//  Copyright © 2026 Aika Yamada. All rights reserved.
//

import XCTest
import Combine
import CombineSchedulers
@testable import ThankYouList

final class ThankYouListViewModelTests: XCTestCase {

    private var viewModel: ThankYouListViewModel!
    private var userRepository: MockUserRepository!
    private var thankYouRepository: MockThankYouRepository!
    private var notificationCenter: MockNotificationCenter!
    private var router: MockThankYouListRouter!

    private var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        userRepository = MockUserRepository()
        thankYouRepository = MockThankYouRepository()
        notificationCenter = MockNotificationCenter()
        router = MockThankYouListRouter()
        scheduler = DispatchQueue.test
        viewModel = ThankYouListViewModel(
            userRepository: userRepository,
            thankYouRepository: thankYouRepository,
            notificationCenterProtocol: notificationCenter,
            router: router,
            scheduler: scheduler.eraseToAnyScheduler()
        )
    }

    func test_ifAUserOpensTheScreen__itShouldCallGetUserProfile() {
        // Open the screen once
        viewModel.inputs.viewDidLoad.send()
        // It should call getUserProfile once
        XCTAssertEqual(userRepository.getUserProfile_calledCount, 1)
    }

    func test_ifAUserOpensTheScreen__itShouldSubscribeThankYouList_andPassUserId() {
        // Set a mock result to return userId on getUserProfile
        let userId = "userId"
        userRepository.getUserProfile_result = Just(Profile(id: userId, name: "", email: "", imageUrl: nil)).setFailureType(to: Error.self).asFuture()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // It should call subscribeThankYouList
        XCTAssertEqual(thankYouRepository.subscribeThankYouList_calledCount, 1)
        // It should pass userId
        XCTAssertEqual(thankYouRepository.subscribeThankYouList_userId, userId)
    }

    func test_ifAUserOpensTheScreen_andGetUserProfileFails__itShouldPresentErrorAlert() {
        // Set an error result on getUserProfile
        userRepository.getUserProfile_result = Fail(error: UserRepositoryError.currentUserNotExist).asFuture()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // It should present an error alert
        XCTAssertEqual(router.presentAlert_calledCount, 1)
        XCTAssertEqual(router.presentAlert_title, R.string.localizable.thank_you_list_load_error_title())
        XCTAssertEqual(router.presentAlert_message, R.string.localizable.thank_you_list_load_error_message())
    }

    func test_ifAUserOpensTheScreen_andSubscribeThankYouListEmitsError__itShouldPresentErrorAlert() {
        // Set subscribeThankYouList to emit an error case
        thankYouRepository.subscribeThankYouList_result = Just(.error(ThankYouRepositoryError.snapshotNotFound)).eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // It should present an error alert
        XCTAssertEqual(router.presentAlert_calledCount, 1)
        XCTAssertEqual(router.presentAlert_title, R.string.localizable.thank_you_list_load_error_title())
        XCTAssertEqual(router.presentAlert_message, R.string.localizable.thank_you_list_load_error_message())
    }

    func test_ifSubscribeThankYouListEmitsAdded_withEmptyList__itShouldAddThankYouToList() {
        let listSectionsRecords = TestRecord(publisher: viewModel.outputs.listSections.eraseToAnyPublisher())
        listSectionsRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Emit added event
        let date = Date(timeIntervalSince1970: 123)
        let thankYou = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date, createTime: Date())
        thankYouRelay.send(.added(thankYou))

        // It should add thank you to list
        XCTAssertEqual(listSectionsRecords.results.count, 1)
        XCTAssertEqual(listSectionsRecords.results, [.value([.init(yearMonthKey: date.toString(format: Date.listYearMonthKeyFormat), items: [thankYou])])])
    }

    func test_ifSubscribeThankYouListEmitsAdded_toExistingSection__itShouldInsertInSortedOrder() {
        let listSectionsRecords = TestRecord(publisher: viewModel.outputs.listSections.eraseToAnyPublisher())
        listSectionsRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Add first thank you
        let date1 = Date(timeIntervalSince1970: 100)
        let thankYou1 = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date1, createTime: Date())
        thankYouRelay.send(.added(thankYou1))

        // Add second thank you (newer date)
        let date2 = Date(timeIntervalSince1970: 200)
        let thankYou2 = ThankYouData(id: "id2", value: "value2", encryptedValue: "", date: date2, createTime: Date())
        thankYouRelay.send(.added(thankYou2))

        // Add third thank you (older date)
        let date3 = Date(timeIntervalSince1970: 50)
        let thankYou3 = ThankYouData(id: "id3", value: "value3", encryptedValue: "", date: date3, createTime: Date())
        thankYouRelay.send(.added(thankYou3))

        // It should maintain sorted order (newest first)
        let dateKey = date1.toString(format: Date.listYearMonthKeyFormat)
        XCTAssertEqual(listSectionsRecords.results, [
            .value([.init(yearMonthKey: dateKey, items: [thankYou1])]),
            .value([.init(yearMonthKey: dateKey, items: [thankYou2, thankYou1])]),
            .value([.init(yearMonthKey: dateKey, items: [thankYou2, thankYou1, thankYou3])]),
        ])
    }

    func test_ifSubscribeThankYouListEmitsAdded_withDifferentMonths__itShouldCreateMultipleSectionsInSortedOrder() {
        let listSectionsRecords = TestRecord(publisher: viewModel.outputs.listSections.eraseToAnyPublisher())
        listSectionsRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Add thank you in January 2021
        let date1 = Date(timeIntervalSince1970: 1609459200) // 2021-01-01
        let thankYou1 = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date1, createTime: Date())
        thankYouRelay.send(.added(thankYou1))

        // Add thank you in March 2021 - should create new section
        let date2 = Date(timeIntervalSince1970: 1614556800) // 2021-03-01
        let thankYou2 = ThankYouData(id: "id2", value: "value2", encryptedValue: "", date: date2, createTime: Date())
        thankYouRelay.send(.added(thankYou2))

        // Add thank you in February 2021 - should insert between them
        let date3 = Date(timeIntervalSince1970: 1612137600) // 2021-02-01
        let thankYou3 = ThankYouData(id: "id3", value: "value3", encryptedValue: "", date: date3, createTime: Date())
        thankYouRelay.send(.added(thankYou3))

        // It should create 3 sections sorted by month (newest first)
        let dateKey1 = date1.toString(format: Date.listYearMonthKeyFormat)
        let dateKey2 = date2.toString(format: Date.listYearMonthKeyFormat)
        let dateKey3 = date3.toString(format: Date.listYearMonthKeyFormat)
        XCTAssertEqual(listSectionsRecords.results, [
            .value([.init(yearMonthKey: dateKey1, items: [thankYou1])]),
            .value([
                .init(yearMonthKey: dateKey2, items: [thankYou2]),
                .init(yearMonthKey: dateKey1, items: [thankYou1])
            ]),
            .value([
                .init(yearMonthKey: dateKey2, items: [thankYou2]),
                .init(yearMonthKey: dateKey3, items: [thankYou3]),
                .init(yearMonthKey: dateKey1, items: [thankYou1])
            ]),
        ])
    }

    func test_ifSubscribeThankYouListEmitsRemoved__itShouldRemoveThankYouFromList() {
        let listSectionsRecords = TestRecord(publisher: viewModel.outputs.listSections.eraseToAnyPublisher())
        listSectionsRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Add thank yous
        let thankYou1 = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: Date(timeIntervalSince1970: 100), createTime: Date())
        let date2 = Date(timeIntervalSince1970: 200)
        let thankYou2 = ThankYouData(id: "id2", value: "value2", encryptedValue: "", date: date2, createTime: Date())
        thankYouRelay.send(.added(thankYou1))
        thankYouRelay.send(.added(thankYou2))
        listSectionsRecords.clearResult()

        // Remove thankYou1
        thankYouRelay.send(.removed(thankYou1))

        // It should remove thankYou1 from list
        let dateKey = date2.toString(format: Date.listYearMonthKeyFormat)
        XCTAssertEqual(listSectionsRecords.results, [
            .value([.init(yearMonthKey: dateKey, items: [thankYou2])])
        ])
    }

    func test_ifSubscribeThankYouListEmitsRemoved_andSectionBecomesEmpty__itShouldRemoveSection() {
        let listSectionsRecords = TestRecord(publisher: viewModel.outputs.listSections.eraseToAnyPublisher())
        listSectionsRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Add single thank you
        let date = Date(timeIntervalSince1970: 100)
        let thankYou = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date, createTime: Date())
        thankYouRelay.send(.added(thankYou))
        listSectionsRecords.clearResult()

        // Remove the only thank you
        thankYouRelay.send(.removed(thankYou))

        // It should remove the entire section
        XCTAssertEqual(listSectionsRecords.results, [
            .value([])
        ])
    }

    func test_ifSubscribeThankYouListEmitsRemoved_fromMultipleSections__itShouldOnlyRemoveFromCorrectSection() {
        let listSectionsRecords = TestRecord(publisher: viewModel.outputs.listSections.eraseToAnyPublisher())
        listSectionsRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Add thank yous in different months
        let date1 = Date(timeIntervalSince1970: 1609459200) // 2021-01-01
        let date2 = Date(timeIntervalSince1970: 1614556800) // 2021-03-01
        let thankYou1 = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date1, createTime: Date())
        let thankYou2 = ThankYouData(id: "id2", value: "value2", encryptedValue: "", date: date2, createTime: Date())
        thankYouRelay.send(.added(thankYou1))
        thankYouRelay.send(.added(thankYou2))
        listSectionsRecords.clearResult()

        // Remove thankYou1 from January section
        thankYouRelay.send(.removed(thankYou1))

        // It should remove January section but keep March section
        let dateKey2 = date2.toString(format: Date.listYearMonthKeyFormat)
        XCTAssertEqual(listSectionsRecords.results, [
            .value([.init(yearMonthKey: dateKey2, items: [thankYou2])])
        ])
    }

    func test_ifSubscribeThankYouListEmitsRemoved_withNonExistentId__itShouldNotChangeList() {
        let listSectionsRecords = TestRecord(publisher: viewModel.outputs.listSections.eraseToAnyPublisher())
        listSectionsRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Add thank you
        let date = Date(timeIntervalSince1970: 100)
        let thankYou = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date, createTime: Date())
        thankYouRelay.send(.added(thankYou))
        listSectionsRecords.clearResult()

        // Try to remove non-existent thank you
        let nonExistentThankYou = ThankYouData(id: "non-existent-id", value: "value", encryptedValue: "", date: date, createTime: Date())
        thankYouRelay.send(.removed(nonExistentThankYou))

        // List should remain unchanged -> No new record
        let dateKey = date.toString(format: Date.listYearMonthKeyFormat)
        XCTAssertTrue(listSectionsRecords.results.isEmpty)
    }

    func test_ifSubscribeThankYouListEmitsUpdated_withSameDate__itShouldUpdateThankYouInPlace() {
        let listSectionsRecords = TestRecord(publisher: viewModel.outputs.listSections.eraseToAnyPublisher())
        listSectionsRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Add thank you
        let date = Date(timeIntervalSince1970: 100)
        let thankYou = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date, createTime: Date())
        thankYouRelay.send(.added(thankYou))
        listSectionsRecords.clearResult()

        // Update thank you with same date
        let updatedThankYou = ThankYouData(id: "id1", value: "updated value", encryptedValue: "", date: date, createTime: Date())
        thankYouRelay.send(.updated(from: thankYou, to: updatedThankYou))

        // It should update the thank you in list
        let dateKey = date.toString(format: Date.listYearMonthKeyFormat)
        XCTAssertEqual(listSectionsRecords.results, [
            .value([.init(yearMonthKey: dateKey, items: [updatedThankYou])])
        ])
    }

    func test_ifSubscribeThankYouListEmitsUpdated_withDifferentDateInSameSection__itShouldReorderWithinSection() {
        let listSectionsRecords = TestRecord(publisher: viewModel.outputs.listSections.eraseToAnyPublisher())
        listSectionsRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Add two thank yous in same section
        let date1 = Date(timeIntervalSince1970: 100)
        let date2 = Date(timeIntervalSince1970: 200)
        let thankYou1 = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date1, createTime: Date())
        let thankYou2 = ThankYouData(id: "id2", value: "value2", encryptedValue: "", date: date2, createTime: Date())
        thankYouRelay.send(.added(thankYou1))
        thankYouRelay.send(.added(thankYou2))
        listSectionsRecords.clearResult()

        // Update thankYou1 to have a newer date (should move to top)
        let newDate = Date(timeIntervalSince1970: 300)
        let updatedThankYou1 = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: newDate, createTime: Date())
        thankYouRelay.send(.updated(from: thankYou1, to: updatedThankYou1))

        // It should reorder - updatedThankYou1 should now be first
        let dateKey = date1.toString(format: Date.listYearMonthKeyFormat)
        XCTAssertEqual(listSectionsRecords.results, [
            .value([.init(yearMonthKey: dateKey, items: [updatedThankYou1, thankYou2])])
        ])
    }

    func test_ifSubscribeThankYouListEmitsUpdated_withDifferentMonth__itShouldMoveToNewSection() {
        let listSectionsRecords = TestRecord(publisher: viewModel.outputs.listSections.eraseToAnyPublisher())
        listSectionsRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Add thank you in January 2021
        let date1 = Date(timeIntervalSince1970: 1609459200) // 2021-01-01
        let thankYou = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date1, createTime: Date())
        thankYouRelay.send(.added(thankYou))
        listSectionsRecords.clearResult()

        // Update thank you to March 2021
        let newDate = Date(timeIntervalSince1970: 1614556800) // 2021-03-01
        let updatedThankYou = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: newDate, createTime: Date())
        thankYouRelay.send(.updated(from: thankYou, to: updatedThankYou))

        // It should move to new section (January section should be removed)
        let newDateKey = newDate.toString(format: Date.listYearMonthKeyFormat)
        XCTAssertEqual(listSectionsRecords.results, [
            .value([.init(yearMonthKey: newDateKey, items: [updatedThankYou])])
        ])
    }

    func test_ifSubscribeThankYouListEmitsUpdated_withDifferentMonth_andOldSectionHasOtherItems__itShouldKeepOldSection() {
        let listSectionsRecords = TestRecord(publisher: viewModel.outputs.listSections.eraseToAnyPublisher())
        listSectionsRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Add two thank yous in January 2021
        let date1 = Date(timeIntervalSince1970: 1609459200) // 2021-01-01
        let date2 = Date(timeIntervalSince1970: 1609545600) // 2021-01-02
        let thankYou1 = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date1, createTime: Date())
        let thankYou2 = ThankYouData(id: "id2", value: "value2", encryptedValue: "", date: date2, createTime: Date())
        thankYouRelay.send(.added(thankYou1))
        thankYouRelay.send(.added(thankYou2))
        listSectionsRecords.clearResult()

        // Update thankYou1 to March 2021
        let newDate = Date(timeIntervalSince1970: 1614556800) // 2021-03-01
        let updatedThankYou1 = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: newDate, createTime: Date())
        thankYouRelay.send(.updated(from: thankYou1, to: updatedThankYou1))

        // It should create new section for March and keep January with thankYou2
        let oldDateKey = date1.toString(format: Date.listYearMonthKeyFormat)
        let newDateKey = newDate.toString(format: Date.listYearMonthKeyFormat)
        XCTAssertEqual(listSectionsRecords.results, [
            .value([
                .init(yearMonthKey: newDateKey, items: [updatedThankYou1]),
                .init(yearMonthKey: oldDateKey, items: [thankYou2])
            ])
        ])
    }

    func test_whenListSectionsChanges__reloadTableViewShouldEmitAfterDebounce() {
        let reloadTableViewRecords = TestRecord(publisher: viewModel.outputs.reloadTableView.map { "" }.eraseToAnyPublisher())

        // Directly send to listSections
        let date = Date(timeIntervalSince1970: 100)
        let section = ThankYouListViewController.ListSection(
            yearMonthKey: date.toString(format: Date.listYearMonthKeyFormat),
            items: [ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date, createTime: Date())]
        )
        viewModel.outputs.listSections.send([section])

        // Should not emit immediately (debounced)
        XCTAssertEqual(reloadTableViewRecords.results, [])

        // Advance scheduler by debounce duration
        scheduler.advance(by: .milliseconds(500))

        // Should emit after debounce
        XCTAssertEqual(reloadTableViewRecords.results, [.value("")])
    }

    func test_whenListSectionsChangesMultipleTimes__reloadTableViewShouldOnlyEmitOnceAfterDebounce() {
        let reloadTableViewRecords = TestRecord(publisher: viewModel.outputs.reloadTableView.map { "" }.eraseToAnyPublisher())

        // Send multiple changes rapidly
        let date1 = Date(timeIntervalSince1970: 100)
        let date2 = Date(timeIntervalSince1970: 200)
        let date3 = Date(timeIntervalSince1970: 300)

        let section1 = ThankYouListViewController.ListSection(
            yearMonthKey: date1.toString(format: Date.listYearMonthKeyFormat),
            items: [ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date1, createTime: Date())]
        )
        viewModel.outputs.listSections.send([section1])
        scheduler.advance(by: .milliseconds(100))

        let section2 = ThankYouListViewController.ListSection(
            yearMonthKey: date2.toString(format: Date.listYearMonthKeyFormat),
            items: [
                ThankYouData(id: "id2", value: "value2", encryptedValue: "", date: date2, createTime: Date()),
                ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date1, createTime: Date())
            ]
        )
        viewModel.outputs.listSections.send([section2])
        scheduler.advance(by: .milliseconds(100))

        let section3 = ThankYouListViewController.ListSection(
            yearMonthKey: date3.toString(format: Date.listYearMonthKeyFormat),
            items: [
                ThankYouData(id: "id3", value: "value3", encryptedValue: "", date: date3, createTime: Date()),
                ThankYouData(id: "id2", value: "value2", encryptedValue: "", date: date2, createTime: Date()),
                ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date1, createTime: Date())
            ]
        )
        viewModel.outputs.listSections.send([section3])

        // Should not emit yet (within debounce window)
        XCTAssertEqual(reloadTableViewRecords.results, [])

        // Advance scheduler to complete debounce
        scheduler.advance(by: .milliseconds(500))

        // Should emit only once (latest value after debounce)
        XCTAssertEqual(reloadTableViewRecords.results, [.value("")])
    }

    func test_whenListSectionsEmitsSameValueTwice__reloadTableViewShouldOnlyEmitOnce() {
        let reloadTableViewRecords = TestRecord(publisher: viewModel.outputs.reloadTableView.map { "" }.eraseToAnyPublisher())

        // Send same section twice
        let date = Date(timeIntervalSince1970: 100)
        let section = ThankYouListViewController.ListSection(
            yearMonthKey: date.toString(format: Date.listYearMonthKeyFormat),
            items: [ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date, createTime: Date())]
        )

        viewModel.outputs.listSections.send([section])
        scheduler.advance(by: .milliseconds(500))
        reloadTableViewRecords.clearResult()

        // Send same section again
        viewModel.outputs.listSections.send([section])
        scheduler.advance(by: .milliseconds(500))

        // Should not emit because the list didn't actually change (duplicate was filtered)
        XCTAssertEqual(reloadTableViewRecords.results, [])
    }

    func test_whenListSectionsChangesAfterDebouncePeriod__reloadTableViewShouldEmitMultipleTimes() {
        let reloadTableViewRecords = TestRecord(publisher: viewModel.outputs.reloadTableView.map { "" }.eraseToAnyPublisher())

        // Send first section
        let date1 = Date(timeIntervalSince1970: 100)
        let section1 = ThankYouListViewController.ListSection(
            yearMonthKey: date1.toString(format: Date.listYearMonthKeyFormat),
            items: [ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date1, createTime: Date())]
        )
        viewModel.outputs.listSections.send([section1])
        scheduler.advance(by: .milliseconds(500))

        // Send second section after debounce period
        let date2 = Date(timeIntervalSince1970: 200)
        let section2 = ThankYouListViewController.ListSection(
            yearMonthKey: date2.toString(format: Date.listYearMonthKeyFormat),
            items: [
                ThankYouData(id: "id2", value: "value2", encryptedValue: "", date: date2, createTime: Date()),
                ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date1, createTime: Date())
            ]
        )
        viewModel.outputs.listSections.send([section2])
        scheduler.advance(by: .milliseconds(500))

        // Should emit twice (once per debounce window)
        XCTAssertEqual(reloadTableViewRecords.results, [.value(""), .value("")])
    }

    func test_whenViewModelIsInitialized__shouldShowSkeletonShouldBeTrue() {
        let shouldShowSkeletonRecords = TestRecord(publisher: viewModel.outputs.shouldShowSkeleton.eraseToAnyPublisher())
        // Initially should show skeleton
        XCTAssertEqual(shouldShowSkeletonRecords.results, [.value(true)])
    }

    func test_ifAUserOpensTheScreen_andDataLoads__shouldShowSkeletonShouldBeFalse() {
        let shouldShowSkeletonRecords = TestRecord(publisher: viewModel.outputs.shouldShowSkeleton.eraseToAnyPublisher())
        shouldShowSkeletonRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Still showing skeleton (no data emitted yet)
        XCTAssertTrue(viewModel.outputs.shouldShowSkeleton.value)

        // Data arrives
        let thankYou = ThankYouData(id: "id", value: "value", encryptedValue: "", date: Date(), createTime: Date())
        thankYouRelay.send(.added(thankYou))

        // Skeleton should be hidden
        XCTAssertEqual(shouldShowSkeletonRecords.results, [.value(false)])
    }

    func test_ifAUserOpensTheScreen_andEmptyListLoads__shouldShowSkeletonShouldBeFalse() {
        let shouldShowSkeletonRecords = TestRecord(publisher: viewModel.outputs.shouldShowSkeleton.eraseToAnyPublisher())
        shouldShowSkeletonRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Emit removed event (simulating empty list after initial load)
        let thankYou = ThankYouData(id: "id", value: "value", encryptedValue: "", date: Date(), createTime: Date())
        thankYouRelay.send(.removed(thankYou))

        // Skeleton should be hidden even though list is empty
        XCTAssertEqual(shouldShowSkeletonRecords.results, [.value(false)])
    }

    func test_ifAUserOpensTheScreen_andErrorOccurs__shouldShowSkeletonShouldBeFalse() {
        let shouldShowSkeletonRecords = TestRecord(publisher: viewModel.outputs.shouldShowSkeleton.eraseToAnyPublisher())
        shouldShowSkeletonRecords.clearResult()

        thankYouRepository.subscribeThankYouList_result = Just(.error(ThankYouRepositoryError.snapshotNotFound)).eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Skeleton should be hidden even on error
        XCTAssertEqual(shouldShowSkeletonRecords.results, [.value(false)])
    }

    func test_ifSubscribeThankYouListEmitsInitial_withEmptyList__itShouldEmitEmptyListOnce_andHideSkeleton() {
        let listSectionsRecords = TestRecord(publisher: viewModel.outputs.listSections.eraseToAnyPublisher())
        listSectionsRecords.clearResult()

        let shouldShowSkeletonRecords = TestRecord(publisher: viewModel.outputs.shouldShowSkeleton.eraseToAnyPublisher())
        shouldShowSkeletonRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Emit initial
        thankYouRelay.send(.initial)

        // .initial does not mutate list (still empty), but first emission flows through
        XCTAssertEqual(listSectionsRecords.results, [.value([])])
        // Skeleton should be hidden after first stream emission
        XCTAssertEqual(shouldShowSkeletonRecords.results, [.value(false)])
    }

    func test_ifSubscribeThankYouListEmitsInitial_afterAdded__itShouldNotEmitListSectionsAgain_dueToRemoveDuplicates() {
        let listSectionsRecords = TestRecord(publisher: viewModel.outputs.listSections.eraseToAnyPublisher())
        listSectionsRecords.clearResult()

        let thankYouRelay = PassthroughSubject<ThankYouListChange, Never>()
        thankYouRepository.subscribeThankYouList_result = thankYouRelay.eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // Add one item
        let date = Date(timeIntervalSince1970: 123)
        let thankYou = ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date, createTime: Date())
        thankYouRelay.send(.added(thankYou))

        let dateKey = date.toString(format: Date.listYearMonthKeyFormat)
        XCTAssertEqual(listSectionsRecords.results, [
            .value([.init(yearMonthKey: dateKey, items: [thankYou])])
        ])

        listSectionsRecords.clearResult()

        // Emit initial again -> scan returns same list, removeDuplicates should suppress
        thankYouRelay.send(.initial)

        XCTAssertEqual(listSectionsRecords.results, [])
    }

    func test_whenViewModelIsInitialized__showEmptyViewShouldBeFalse() {
        let showEmptyViewRecords = TestRecord(publisher: viewModel.outputs.showEmptyView.eraseToAnyPublisher())

        // Initial state should be false (not empty yet, just not loaded)
        XCTAssertEqual(showEmptyViewRecords.results, [.value(false)])
    }

    func test_whenListSectionsHasItems__showEmptyViewShouldBeFalse() {
        let showEmptyViewRecords = TestRecord(publisher: viewModel.outputs.showEmptyView.eraseToAnyPublisher())
        showEmptyViewRecords.clearResult()

        // Add items to list
        let date = Date(timeIntervalSince1970: 100)
        viewModel.outputs.listSections.send([.init(
            yearMonthKey: date.toString(format: Date.listYearMonthKeyFormat),
            items: [ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date, createTime: Date())]
        )])

        // showEmptyView should be false (list has items)
        XCTAssertEqual(showEmptyViewRecords.results, [.value(false)])
    }

    func test_whenFirstEmissionIsEmpty__showEmptyViewShouldBeTrue() {
        let showEmptyViewRecords = TestRecord(publisher: viewModel.outputs.showEmptyView.eraseToAnyPublisher())
        showEmptyViewRecords.clearResult()

        // Send empty list (simulating empty list after loading)
        viewModel.outputs.listSections.send([])

        // showEmptyView should emit true (first real emission after dropFirst)
        XCTAssertEqual(showEmptyViewRecords.results, [.value(true)])
    }

    func test_whenListSectionsBecomesEmpty__showEmptyViewShouldBeTrue() {
        let showEmptyViewRecords = TestRecord(publisher: viewModel.outputs.showEmptyView.eraseToAnyPublisher())
        showEmptyViewRecords.clearResult()

        // Add items to list
        let date = Date(timeIntervalSince1970: 100)
        viewModel.outputs.listSections.send([.init(
            yearMonthKey: date.toString(format: Date.listYearMonthKeyFormat),
            items: [ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date, createTime: Date())]
        )])

        // showEmptyView should be false (list is not empty)
        XCTAssertEqual(showEmptyViewRecords.results, [.value(false)])
        showEmptyViewRecords.clearResult()

        // Make list empty
        viewModel.outputs.listSections.send([])

        // showEmptyView should be true (list is now empty)
        XCTAssertEqual(showEmptyViewRecords.results, [.value(true)])
    }

    func test_whenListSectionsChangesFromEmptyToNotEmpty__showEmptyViewShouldBeFalse() {
        let showEmptyViewRecords = TestRecord(publisher: viewModel.outputs.showEmptyView.eraseToAnyPublisher())
        showEmptyViewRecords.clearResult()

        // Send empty list
        viewModel.outputs.listSections.send([])
        XCTAssertEqual(showEmptyViewRecords.results, [.value(true)])
        showEmptyViewRecords.clearResult()

        // Add items to list
        let date = Date(timeIntervalSince1970: 100)
        viewModel.outputs.listSections.send([.init(
            yearMonthKey: date.toString(format: Date.listYearMonthKeyFormat),
            items: [ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date, createTime: Date())]
        )])

        // showEmptyView should be false (list now has items)
        XCTAssertEqual(showEmptyViewRecords.results, [.value(false)])
    }

    func test_whenListSectionsStaysEmpty__showEmptyViewShouldStayTrue() {
        let showEmptyViewRecords = TestRecord(publisher: viewModel.outputs.showEmptyView.eraseToAnyPublisher())
        showEmptyViewRecords.clearResult()

        // Send empty list
        viewModel.outputs.listSections.send([])
        XCTAssertEqual(showEmptyViewRecords.results, [.value(true)])
        showEmptyViewRecords.clearResult()

        // Send empty list again
        viewModel.outputs.listSections.send([])

        // showEmptyView should not emit again (removed by removeDuplicates)
        XCTAssertEqual(showEmptyViewRecords.results, [])
    }

    func test_whenListSectionsStaysNonEmpty__showEmptyViewShouldNotEmitDuplicateFalse() {
        let showEmptyViewRecords = TestRecord(publisher: viewModel.outputs.showEmptyView.eraseToAnyPublisher())
        showEmptyViewRecords.clearResult()

        // First non-empty list -> emits false
        let date1 = Date(timeIntervalSince1970: 100)
        viewModel.outputs.listSections.send([.init(
            yearMonthKey: date1.toString(format: Date.listYearMonthKeyFormat),
            items: [ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date1, createTime: Date())]
        )])
        XCTAssertEqual(showEmptyViewRecords.results, [.value(false)])
        showEmptyViewRecords.clearResult()

        // Another non-empty list -> still false, should be removed by removeDuplicates()
        let date2 = Date(timeIntervalSince1970: 200)
        viewModel.outputs.listSections.send([.init(
            yearMonthKey: date2.toString(format: Date.listYearMonthKeyFormat),
            items: [ThankYouData(id: "id2", value: "value2", encryptedValue: "", date: date2, createTime: Date())]
        )])

        XCTAssertEqual(showEmptyViewRecords.results, [])
    }

    func test_whenListSectionsChanges__itShouldPostThankYouListUpdatedNotification_afterDebounce() {
        // Subscribe to reloadTableView to create demand (make the subscription in VM work)
        _ = viewModel.outputs.reloadTableView.sink { _ in }

        let date = Date(timeIntervalSince1970: 100)
        let section = ThankYouListViewController.ListSection(
            yearMonthKey: date.toString(format: Date.listYearMonthKeyFormat),
            items: [ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date, createTime: Date())]
        )
        viewModel.outputs.listSections.send([section])

        // Should not post before debounce completes
        XCTAssertEqual(notificationCenter.post_calledCount, 0)

        // Advance scheduler past debounce duration
        scheduler.advance(by: .milliseconds(500))

        // Should post exactly once with the correct notification name
        XCTAssertEqual(notificationCenter.post_calledCount, 1)
        XCTAssertEqual(
            notificationCenter.post_notifications.first?.name,
            Notification.Name(rawValue: NotificationConst.THANK_YOU_LIST_UPDATED)
        )
    }

    func test_whenListSectionsChangesMultipleTimes_withinDebounceWindow__itShouldPostNotificationOnlyOnce() {
        // Subscribe to reloadTableView to create demand (make the subscription in VM work)
        _ = viewModel.outputs.reloadTableView.sink { _ in }

        let date1 = Date(timeIntervalSince1970: 100)
        let date2 = Date(timeIntervalSince1970: 200)

        let section1 = ThankYouListViewController.ListSection(
            yearMonthKey: date1.toString(format: Date.listYearMonthKeyFormat),
            items: [ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date1, createTime: Date())]
        )
        let section2 = ThankYouListViewController.ListSection(
            yearMonthKey: date2.toString(format: Date.listYearMonthKeyFormat),
            items: [ThankYouData(id: "id2", value: "value2", encryptedValue: "", date: date2, createTime: Date())]
        )

        viewModel.outputs.listSections.send([section1])
        scheduler.advance(by: .milliseconds(100))
        viewModel.outputs.listSections.send([section2])
        scheduler.advance(by: .milliseconds(500))

        // Debounce should collapse rapid changes into a single notification
        XCTAssertEqual(notificationCenter.post_calledCount, 1)
    }

    func test_whenListSectionsEmitsSameValue__itShouldNotPostNotificationAgain() {
        // Subscribe to reloadTableView to create demand (make the subscription in VM work)
        _ = viewModel.outputs.reloadTableView.sink { _ in }

        let date = Date(timeIntervalSince1970: 100)
        let section = ThankYouListViewController.ListSection(
            yearMonthKey: date.toString(format: Date.listYearMonthKeyFormat),
            items: [ThankYouData(id: "id1", value: "value1", encryptedValue: "", date: date, createTime: Date())]
        )

        viewModel.outputs.listSections.send([section])
        scheduler.advance(by: .milliseconds(500))
        XCTAssertEqual(notificationCenter.post_calledCount, 1)

        // Send the same value again
        viewModel.outputs.listSections.send([section])
        scheduler.advance(by: .milliseconds(500))

        // removeDuplicates should suppress the second notification
        XCTAssertEqual(notificationCenter.post_calledCount, 1)
    }

    func test_ifUserTapsUserIcon__itShouldShowMyPage() {
        viewModel.inputs.userIconDidTap.send()
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(router.presentMyPage_calledCount, 1)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasNilRawValue__itShouldNotEitherPresentEditThankYouOrPresentAlert() {
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "", image: nil, rawValue: nil, id: "123")
        )
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(router.presentEditThankYou_calledCount, 0)
        XCTAssertEqual(router.presentAlert_calledCount, 0)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasNotExistingThankYouCellTapMenuRawValue__itShouldNotEitherPresentEditThankYouOrPresentAlert() {
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "", image: nil, rawValue: 2, id: "123")
        )
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(router.presentEditThankYou_calledCount, 0)
        XCTAssertEqual(router.presentAlert_calledCount, 0)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasAvailableRawValue_andNilId__itShouldNotEitherPresentEditThankYouOrPresentAlert() {
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.edit.rawValue,
                  id: nil)
        )
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(router.presentEditThankYou_calledCount, 0)
        XCTAssertEqual(router.presentAlert_calledCount, 0)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasEditValue__itShouldDismissPresentedView_andPresentEditThankYou_withPassedThankYouId() {
        let dismissPresentedViewRecords = TestRecord(
            publisher: viewModel.outputs.dismissPresentedView.map { "" }.eraseToAnyPublisher())

        let thankYouId = "thank you id"
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.edit.rawValue,
                  id: thankYouId)
        )
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(dismissPresentedViewRecords.results, [.value("")])
        XCTAssertEqual(router.presentEditThankYou_calledCount, 1)
        XCTAssertEqual(router.presentEditThankYou_thankYouId, thankYouId)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasDeleteValue__itShouldDismissPresentedView_andPresentAlert() {
        let dismissPresentedViewRecords = TestRecord(
            publisher: viewModel.outputs.dismissPresentedView.map { "" }.eraseToAnyPublisher())

        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.delete.rawValue,
                  id: "thankYouId")
        )
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(dismissPresentedViewRecords.results, [.value("")])
        XCTAssertEqual(router.presentAlert_calledCount, 1)
        XCTAssertEqual(router.presentAlert_title, R.string.localizable.deleteThankYou())
        XCTAssertEqual(router.presentAlert_message, R.string.localizable.areYouSureYouWantToDeleteThisThankYou())
        let firstAction = router.presentAlert_actions?.first
        XCTAssertEqual(firstAction?.title, R.string.localizable.delete())
        XCTAssertEqual(firstAction?.style, .destructive)
        let secondAction = router.presentAlert_actions?[1]
        XCTAssertEqual(secondAction?.title, R.string.localizable.cancel())
        XCTAssertEqual(secondAction?.style, .cancel)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasDeleteValue_andTapsDeleteButton__itShouldCallDeleteThankYou__andEvenIfTheFirstTryFails__itShouldCallDeleteThankYouAgain() {

        // Tap delete button on menu
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.delete.rawValue,
                  id: "thankYouId")
        )
        scheduler.advance(by: .milliseconds(100))

        let deleteAction = router.presentAlert_actions?.first

        // Set delete thank you first result as failed
        thankYouRepository.deleteThankYou_result = Fail(error: NSError()).asFuture()

        // Tap delete button on confirmation halfsheet #1
        deleteAction?.action!()

        // deleteThankYou should be called once
        XCTAssertEqual(thankYouRepository.deleteThankYou_calledCount, 1)

        // Set delete thank you first result as success
        thankYouRepository.deleteThankYou_result = Just(()).setFailureType(to: Error.self).asFuture()

        // Tap delete button on confirmation halfsheet #2
        deleteAction?.action!()

        // deleteThankYou should be called twice
        XCTAssertEqual(thankYouRepository.deleteThankYou_calledCount, 2)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasDeleteValue_tapsDeleteButton_andDeleteSucceeded__itShouldNotPresentAlertTwice() {

        let userId = "userId"
        userRepository.getUserProfile_result = Just(Profile(id: userId, name: "", email: "", imageUrl: nil)).setFailureType(to: Error.self).asFuture()
        let thankYouDate = Date(timeIntervalSince1970: 123456)
        thankYouRepository.loadThankYou_result = ThankYouData(id: "", value: "", encryptedValue: "", date: thankYouDate, createTime: Date())

        // Tap delete button on menu
        let thankYouId = "abcddd"
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.delete.rawValue,
                  id: thankYouId)
        )
        scheduler.advance(by: .milliseconds(100))

        let deleteAction = router.presentAlert_actions?.first

        // Set delete thank you result as success
        thankYouRepository.deleteThankYou_result = Just(()).setFailureType(to: Error.self).asFuture()

        // Tap delete button on confirmation halfsheet #1
        deleteAction?.action!()

        // Should pass correct parameters
        XCTAssertEqual(thankYouRepository.deleteThankYou_thankYouId, thankYouId)
        XCTAssertEqual(thankYouRepository.deleteThankYou_userId, userId)

        // Should not present alert twice
        XCTAssertEqual(router.presentAlert_calledCount, 1)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasDeleteValue_tapsDeleteButton_andDeleteFailed__itShouldPresentAlert() {

        userRepository.getUserProfile_result = Just(Profile(id: "userId", name: "", email: "", imageUrl: nil)).setFailureType(to: Error.self).asFuture()

        // Tap delete button on menu
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.delete.rawValue,
                  id: "thankYouId")
        )
        scheduler.advance(by: .milliseconds(100))

        // Should present alert
        XCTAssertEqual(router.presentAlert_calledCount, 1)
        // Reset
        router.presentAlert_calledCount = 0
        router.presentAlert_message = nil

        let deleteAction = router.presentAlert_actions?.first

        // Set delete thank you result as failure
        thankYouRepository.deleteThankYou_result = Fail(error: NSError()).asFuture()

        // Tap delete button on confirmation halfsheet #1
        deleteAction?.action!()
        scheduler.advance(by: .milliseconds(100))

        // Should present alert
        XCTAssertEqual(router.presentAlert_calledCount, 1)
        XCTAssertEqual(router.presentAlert_message, R.string.localizable.failedToDelete())
    }
}

private class MockThankYouListRouter: MockRouter, ThankYouListRouter {
    var presentMyPage_calledCount = 0
    func presentMyPage() {
        presentMyPage_calledCount += 1
    }

    var presentEditThankYou_calledCount = 0
    var presentEditThankYou_thankYouId: String?
    func presentEditThankYou(thankYouId: String) {
        presentEditThankYou_thankYouId = thankYouId
        presentEditThankYou_calledCount += 1
    }
}
