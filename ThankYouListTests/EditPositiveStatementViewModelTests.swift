//
//  EditPositiveStatementViewModelTests.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2024/09/14.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import XCTest
import Combine
import CombineSchedulers
@testable import ThankYouList

final class EditPositiveStatementViewModelTests: XCTestCase {

    private var viewModel: EditPositiveStatementViewModel!
    private var userRepository: MockUserRepository!
    private var positiveStatementRepository: MockPositiveStatementRepository!
    private var router: MockEditPositiveStatementRouter!

    override func setUp() {
        router = MockEditPositiveStatementRouter()
        userRepository = MockUserRepository()
        positiveStatementRepository = MockPositiveStatementRepository()

        viewModel = EditPositiveStatementViewModel(
            userRepository: userRepository,
            positiveStatementRepository: positiveStatementRepository,
            router: router)
    }

    func test_ifAUserScrollsTheScrollView_moreThanNavBarVisibleOffset__itShouldSetTitleOnNavBarTitle() {
        let navigationBarTitleRecords = TestRecord(
            publisher: viewModel.outputs.$navigationBarTitle.eraseToAnyPublisher()
        )
        navigationBarTitleRecords.clearResult()

        // Scrolls the scrollView more than NavBar visible offset
        viewModel.inputs.scrollViewOffsetDidChange.send(ViewConst.swiftUINavigationTitleVisibleOffset + 1)

        // It should set title
        XCTAssertEqual(navigationBarTitleRecords.results, [.value(R.string.localizable.edit_positive_statement_title())])
        navigationBarTitleRecords.clearResult()
    }

    func test_ifAUserScrollsTheScrollView_equalToOrLessThanNavBarVisibleOffset__itShouldSetEmptyOnNavBarTitle() {
        let navigationBarTitleRecords = TestRecord(
            publisher: viewModel.outputs.$navigationBarTitle.eraseToAnyPublisher()
        )

        // Scrolls the scrollView more than NavBar visible offset first
        viewModel.inputs.scrollViewOffsetDidChange.send(ViewConst.swiftUINavigationTitleVisibleOffset + 10)
        navigationBarTitleRecords.clearResult()

        // Scrolls the scrollView equal to NavBar visible offset
        viewModel.inputs.scrollViewOffsetDidChange.send(ViewConst.swiftUINavigationTitleVisibleOffset)

        // It should set empty title
        XCTAssertEqual(navigationBarTitleRecords.results, [.value("")])
        navigationBarTitleRecords.clearResult()
    }

    func test_ifAUserScrollsTheScrollView__itShouldSetNavBarTitle_byRemovingDuplicates() {
        let navigationBarTitleRecords = TestRecord(
            publisher: viewModel.outputs.$navigationBarTitle.eraseToAnyPublisher()
        )
        navigationBarTitleRecords.clearResult()

        // Scrolls the scrollView more than NavBar visible offset first
        viewModel.inputs.scrollViewOffsetDidChange.send(ViewConst.swiftUINavigationTitleVisibleOffset + 10)

        // It should set title
        XCTAssertEqual(navigationBarTitleRecords.results, [.value(R.string.localizable.edit_positive_statement_title())])
        navigationBarTitleRecords.clearResult()

        // Scrolls the scrollView more
        viewModel.inputs.scrollViewOffsetDidChange.send(ViewConst.swiftUINavigationTitleVisibleOffset + 11)

        // It should not set title twice
        XCTAssertTrue(navigationBarTitleRecords.results.isEmpty)

        // Scrolls the scrollView equal to NavBar visible offset
        viewModel.inputs.scrollViewOffsetDidChange.send(ViewConst.swiftUINavigationTitleVisibleOffset)

        // It should set empty title
        XCTAssertEqual(navigationBarTitleRecords.results, [.value("")])
        navigationBarTitleRecords.clearResult()

        // Scrolls more
        viewModel.inputs.scrollViewOffsetDidChange.send(ViewConst.swiftUINavigationTitleVisibleOffset - 10)

        // It should not set title twice
        XCTAssertTrue(navigationBarTitleRecords.results.isEmpty)
    }

    func test_ifAUserTapsCancelButton__itShouldDismissView() {
        // Taps cancel button
        viewModel.inputs.cancelButtonDidTap.send()

        // Should not call router.dismiss
        XCTAssertEqual(router.dismiss_calledCount, 1)
    }
}

private class MockEditPositiveStatementRouter: MockRouter, EditPositiveStatementRouter {
    var dismiss_calledCount = 0
    func dismiss() {
        dismiss_calledCount += 1
    }
}
