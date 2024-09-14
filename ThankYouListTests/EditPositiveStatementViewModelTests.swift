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

    func test_ifTextFieldDidChange_withLessThan2NewlineCharsInARow__itShouldNotUpdateTextFieldText_orSendCloseKeyboardEvent__viceVersa() {
        let textFieldTextRecords = TestRecord(
            publisher: viewModel.bindings.$textFieldText.eraseToAnyPublisher())
        textFieldTextRecords.clearResult() // Remove the initial record

        let closeKeyboardRecords = TestRecord(
            publisher: viewModel.outputs.closeKeyboard.map { "" }.eraseToAnyPublisher()) // Void cannot be compared

        // textFieldDidChange without 2 newline characters in a row
        viewModel.inputs.textFieldTextDidChange.send("a")
        viewModel.inputs.textFieldTextDidChange.send("ab")
        viewModel.inputs.textFieldTextDidChange.send("abc")
        viewModel.inputs.textFieldTextDidChange.send("abc\n")

        // Should not update textFieldText or closeKeyboard
        XCTAssertTrue(textFieldTextRecords.results.isEmpty)
        XCTAssertTrue(closeKeyboardRecords.results.isEmpty)

        // textFieldDidChange with 2 newline characters in a row
        viewModel.inputs.textFieldTextDidChange.send("abc\n\n")

        // Should update textFieldText with removing the last newline and closeKeyboard
        XCTAssertEqual(textFieldTextRecords.results, [
            (.value("abc\n"))
        ])
        XCTAssertEqual(closeKeyboardRecords.results, [
            (.value(""))
        ])
    }

    func test_ifTextFieldTextUpdated__itShouldUpdateCharacterCounterText_withTheCurrentTextCount() {
        let characterCounterTextRecords = TestRecord(
            publisher: viewModel.outputs.characterCounterText.eraseToAnyPublisher())
        characterCounterTextRecords.clearResult() // Remove the initial record

        let maxCountString = "100"

        // characterCounterText should be updated along with textFieldText
        viewModel.bindings.textFieldText = "a"
        XCTAssertEqual(characterCounterTextRecords.results, [
            .value(R.string.localizable.edit_positive_statement_character_count_text("1", maxCountString))
        ])
        characterCounterTextRecords.clearResult()

        viewModel.bindings.textFieldText = "abcdefghi"
        XCTAssertEqual(characterCounterTextRecords.results, [
            .value(R.string.localizable.edit_positive_statement_character_count_text("9", maxCountString))
        ])
        characterCounterTextRecords.clearResult()

        viewModel.bindings.textFieldText = "abcdefghiあいうえお今晩は😀\n！！"
        XCTAssertEqual(characterCounterTextRecords.results, [
            .value(R.string.localizable.edit_positive_statement_character_count_text("21", maxCountString))
        ])
    }

    func test_ifTextFieldTextUpdated_withLessThanOrEqualTo100Characters__itShouldUpdateCharacterCounterColorAsTextColor__andWithMoreThan100Characters__itShouldUpdateColorAsRedAccent200() {
        let characterCounterColorRecords = TestRecord(
            publisher: viewModel.outputs.characterCounterColor.eraseToAnyPublisher())
        characterCounterColorRecords.clearResult() // Remove the initial record

        // when textFieldText character count is 1, the color should be .text
        viewModel.bindings.textFieldText = "a"
        XCTAssertEqual(characterCounterColorRecords.results, [
            .value(.text)
        ])
        characterCounterColorRecords.clearResult()

        // when textFieldText character count is 99, the color should be .text
        viewModel.bindings.textFieldText = "99characters......................................................................................"
        XCTAssertEqual(characterCounterColorRecords.results, [
            .value(.text)
        ])
        characterCounterColorRecords.clearResult()

        // when textFieldText character count is 100, the color should be .text
        viewModel.bindings.textFieldText = "100characters......................................................................................"
        XCTAssertEqual(characterCounterColorRecords.results, [
            .value(.text)
        ])
        characterCounterColorRecords.clearResult()

        // when textFieldText character count is 101, the color should be .redAccent200
        viewModel.bindings.textFieldText = "101characters........................................................................................."
        XCTAssertEqual(characterCounterColorRecords.results, [
            .value(.redAccent200)
        ])
    }
}

private class MockEditPositiveStatementRouter: MockRouter, EditPositiveStatementRouter {
    var dismiss_calledCount = 0
    func dismiss() {
        dismiss_calledCount += 1
    }
}
