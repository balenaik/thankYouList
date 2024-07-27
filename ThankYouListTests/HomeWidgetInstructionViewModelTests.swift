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

    func test_ifTheUserOpensTheScreen_onPage1__itShouldShowImageForPage1() {
        // Setup page1
        setupViewModel(page: .page1)

        let imageNameRecords = TestRecord(publisher: viewModel.outputs.$imageName.eraseToAnyPublisher())
        imageNameRecords.clearResult()

        // Opens the screen
        viewModel.inputs.onAppear.send()

        // It should show image for Page1
        XCTAssertEqual(imageNameRecords.results, [.value(R.image.imageHomeWidgetInstructionPage1.name)])
    }

    func test_ifTheUserOpensTheScreen_onPage2__itShouldShowImageForPage2() {
        // Setup page2
        setupViewModel(page: .page2)

        let imageNameRecords = TestRecord(publisher: viewModel.outputs.$imageName.eraseToAnyPublisher())
        imageNameRecords.clearResult()

        // Opens the screen
        viewModel.inputs.onAppear.send()

        // It should show image for Page2
        XCTAssertEqual(imageNameRecords.results, [.value(R.image.imageHomeWidgetInstructionPage2.name)])
    }

    func test_ifTheUserOpensTheScreen_onPage3__itShouldShowImageForPage3() {
        // Setup page3
        setupViewModel(page: .page3)

        let imageNameRecords = TestRecord(publisher: viewModel.outputs.$imageName.eraseToAnyPublisher())
        imageNameRecords.clearResult()

        // Opens the screen
        viewModel.inputs.onAppear.send()

        // It should show image for Page3
        XCTAssertEqual(imageNameRecords.results, [.value(R.image.imageHomeWidgetInstructionPage3.name)])
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
