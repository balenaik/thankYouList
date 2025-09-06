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
    private var analyticsManager: MockAnalyticsManager!

    override func setUp() {
        router = MockHomeWidgetInstructionRouter()
        analyticsManager = MockAnalyticsManager()
        setupViewModel(page: .page1)
    }

    private func setupViewModel(page: HomeWidgetinstructionPage) {
        viewModel = HomeWidgetInstructionViewModel(
            page: page,
            router: router,
            analyticsManager: analyticsManager
        )
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

    func test_ifTheUserOpensTheScreen_onPage1__itShouldShowDescriptionForPage1() {
        // Setup page1
        setupViewModel(page: .page1)

        let descriptionRecords = TestRecord(publisher: viewModel.outputs.$description.eraseToAnyPublisher())
        descriptionRecords.clearResult()

        // Opens the screen
        viewModel.inputs.onAppear.send()

        // It should show description for Page1
        XCTAssertEqual(descriptionRecords.results, [.value(R.string.localizable.home_widget_instruction_page1_description())])
    }

    func test_ifTheUserOpensTheScreen_onPage2__itShouldShowDescriptionForPage2() {
        // Setup page2
        setupViewModel(page: .page2)

        let descriptionRecords = TestRecord(publisher: viewModel.outputs.$description.eraseToAnyPublisher())
        descriptionRecords.clearResult()

        // Opens the screen
        viewModel.inputs.onAppear.send()

        // It should show description for Page2
        XCTAssertEqual(descriptionRecords.results, [.value(R.string.localizable.home_widget_instruction_page2_description())])
    }

    func test_ifTheUserOpensTheScreen_onPage3__itShouldShowDescriptionForPage3() {
        // Setup page3
        setupViewModel(page: .page3)

        let descriptionRecords = TestRecord(publisher: viewModel.outputs.$description.eraseToAnyPublisher())
        descriptionRecords.clearResult()

        // Opens the screen
        viewModel.inputs.onAppear.send()

        // It should show description for Page3
        XCTAssertEqual(descriptionRecords.results, [.value(R.string.localizable.home_widget_instruction_page3_description())])
    }

    func test_ifTheUserOpensTheScreen_onPage1__itShouldShowNextOnTheBottomButton() {
        // Setup page1
        setupViewModel(page: .page1)

        let bottomButtonTitleRecords = TestRecord(publisher: viewModel.outputs.$bottomButtonTitle.eraseToAnyPublisher())
        bottomButtonTitleRecords.clearResult()

        // Opens the screen
        viewModel.inputs.onAppear.send()

        // It should show "Next" for bottomButtonTitle
        XCTAssertEqual(bottomButtonTitleRecords.results, [.value(R.string.localizable.next())])
    }

    func test_ifTheUserOpensTheScreen_onPage2__itShouldShowNextOnTheBottomButton() {
        // Setup page2
        setupViewModel(page: .page2)

        let bottomButtonTitleRecords = TestRecord(publisher: viewModel.outputs.$bottomButtonTitle.eraseToAnyPublisher())
        bottomButtonTitleRecords.clearResult()

        // Opens the screen
        viewModel.inputs.onAppear.send()

        // It should show "Next" for bottomButtonTitle
        XCTAssertEqual(bottomButtonTitleRecords.results, [.value(R.string.localizable.next())])
    }

    func test_ifTheUserOpensTheScreen_onPage3__itShouldShowDoneOnTheBottomButton() {
        // Setup page3
        setupViewModel(page: .page3)

        let bottomButtonTitleRecords = TestRecord(publisher: viewModel.outputs.$bottomButtonTitle.eraseToAnyPublisher())
        bottomButtonTitleRecords.clearResult()

        // Opens the screen
        viewModel.inputs.onAppear.send()

        // It should show "Done" for bottomButtonTitle
        XCTAssertEqual(bottomButtonTitleRecords.results, [.value(R.string.localizable.done())])
    }

    func test_ifTheUserTapsBottomButton_onPage1__itShouldPushToPage2() {
        // Setup page1
        setupViewModel(page: .page1)

        // Taps bottom button
        viewModel.inputs.bottomButtomDidTap.send()

        // It should push to page2
        XCTAssertEqual(router.pushToPage2_calledCount, 1)
    }

    func test_ifTheUserTapsBottomButton_onPage2__itShouldPushToPage3() {
        // Setup page2
        setupViewModel(page: .page2)

        // Taps bottom button
        viewModel.inputs.bottomButtomDidTap.send()

        // It should push to page3
        XCTAssertEqual(router.pushToPage3_calledCount, 1)
    }

    func test_ifTheUserTapsBottomButton_onPage3__itShouldDismiss() {
        // Setup page3
        setupViewModel(page: .page3)

        // Taps bottom button
        viewModel.inputs.bottomButtomDidTap.send()

        // It should dismiss
        XCTAssertEqual(router.dismiss_calledCount, 1)
    }

    func test_ifTheUserTapsCancelButton__itShouldDismissView() {
        // Taps cancel button
        viewModel.inputs.cancelButtonDidTap.send()

        // It should dismiss view
        XCTAssertEqual(router.dismiss_calledCount, 1)
    }

    func test_ifTheUserOpensTheScreen__itShouldLogEvent() {
        viewModel.inputs.onAppear.send()
        XCTAssertEqual(analyticsManager.loggedEvent.count, 1)
        XCTAssertEqual(analyticsManager.loggedEvent.first?.eventName, AnalyticsEventConst.openHomeWidgetInstruction)
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
