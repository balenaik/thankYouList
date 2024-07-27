//
//  HomeWidgetInstructionViewModelTests.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2024/07/27.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import XCTest

@testable import ThankYouList

final class HomeWidgetInstructionViewModelTests: XCTestCase {

    private var viewModel: HomeWidgetInstructionViewModel!
    private var router: MockHomeWidgetInstructionRouter!

    override func setUp() {
        router = MockHomeWidgetInstructionRouter()
        setupViewModel(page: .page1)
    }

    private func setupViewModel(page: HomeWidgetinstructionPage) {
        viewModel = HomeWidgetInstructionViewModel(
            page: page,
            router: router)
    }

    func test_ifTheUserTapsCancelButton__itShouldDismissView() {
        // Taps cancel button
        viewModel.inputs.cancelButtonDidTap.send()

        // It should dismiss view
        XCTAssertEqual(router.dismiss_calledCount, 1)
    }
}

private class MockHomeWidgetInstructionRouter: HomeWidgetinstructionRouter {
    var pushToPage2_calledCount = 0
    func pushToPage2() {
        pushToPage2_calledCount += 1
    }
    
    var pushToPage3_calledCount = 0
    func pushToPage3() {
        pushToPage3_calledCount += 1
    }
    
    var dismiss_calledCount = 0
    func dismiss() {
        dismiss_calledCount += 1
    }
}
