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
    private var router: MockThankYouListRouter!

    private var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        router = MockThankYouListRouter()
        scheduler = DispatchQueue.test
        viewModel = ThankYouListViewModel(
            router: router,
            scheduler: scheduler.eraseToAnyScheduler()
        )
    }

    func test_ifUserTapsUserIcon__itShouldShowMyPage() {
        viewModel.inputs.userIconDidTap.send()
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(router.presentMyPage_calledCount, 1)
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
