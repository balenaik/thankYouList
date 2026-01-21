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
    private var router: MockThankYouListRouter!

    private var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        userRepository = MockUserRepository()
        thankYouRepository = MockThankYouRepository()
        router = MockThankYouListRouter()
        scheduler = DispatchQueue.test
        viewModel = ThankYouListViewModel(
            userRepository: userRepository,
            thankYouRepository: thankYouRepository,
            router: router,
            scheduler: scheduler.eraseToAnyScheduler()
        )
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
