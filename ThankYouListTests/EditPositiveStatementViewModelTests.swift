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
import SharedResources
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

        setupViewModel(positiveStatementId: "")
    }

    private func setupViewModel(positiveStatementId: String) {
        viewModel = EditPositiveStatementViewModel(
            positiveStatementId: positiveStatementId,
            userRepository: userRepository,
            positiveStatementRepository: positiveStatementRepository,
            router: router
        )
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

    func test_ifAUserTapsDoneButton__itShouldCloseKeyboard() {
        let closeKeyboardRecords = TestRecord(
            publisher: viewModel.outputs.closeKeyboard.map { "" }.eraseToAnyPublisher()) // Void cannot be compared

        // Taps done button
        viewModel.inputs.doneButtonDidTap.send()

        // Should close keyboard
        XCTAssertEqual(closeKeyboardRecords.results, [
            (.value(""))
        ])
    }

    func test_ifAUserOepnsTheScreen__itShouldCallGetUserProfile() {
        // Open the screen
        viewModel.inputs.onAppear.send()

        // Should call getUserProfile
        XCTAssertEqual(userRepository.getUserProfile_calledCount, 1)
    }

    func test_ifAUserOepnsTheScreen__itShouldCallGetPositiveStatement_withPositiveStatementId_andUserId() {
        let positiveStatementId = "positiveStatementId"
        let userId = "userId"

        userRepository.getUserProfile_result = Just(.init(id: userId, name: "", email: "", imageUrl: nil)).setFailureType(to: Error.self).asFuture()
        setupViewModel(positiveStatementId: positiveStatementId)

        // Open the screen
        viewModel.inputs.onAppear.send()

        // Should call getPositiveStatement
        XCTAssertEqual(positiveStatementRepository.getPositiveStatement_calledCount, 1)
        // Parameters should be the same as prepared
        XCTAssertEqual(
            positiveStatementRepository.getPositiveStatement_positiveStatementId,
            positiveStatementId
        )
        XCTAssertEqual(
            positiveStatementRepository.getPositiveStatement_userId,
            userId
        )
    }

    func test_ifAUserOepnsTheScreen__itShouldUpdateTextFieldText() {
        let textFieldTextRecords = TestRecord(
            publisher: viewModel.bindings.$textFieldText.eraseToAnyPublisher())
        textFieldTextRecords.clearResult() // Remove the initial record

        let positiveStatement = "Positive statement"
        positiveStatementRepository.getPositiveStatement_result = Just(
            .init(
                id: "",
                value: positiveStatement,
                createdDate: Date())
        ).setFailureType(to: Error.self).asFuture()

        // Open the screen
        viewModel.inputs.onAppear.send()

        // Should update textFieldText
        XCTAssertEqual(textFieldTextRecords.results, [.value(positiveStatement)])
    }

    func test_ifAUserOepnsTheScreen_andGetUserProfileFails__itShouldShowErrorAlert() {
        let showAlertTitleRecords = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.title).eraseToAnyPublisher())
        let showAlertMessageRecords = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.message).eraseToAnyPublisher())
        let showAlertPrimaryActionTitleRecords = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.primaryAction?.title).eraseToAnyPublisher())
        showAlertTitleRecords.clearResult()
        showAlertMessageRecords.clearResult()
        showAlertPrimaryActionTitleRecords.clearResult()

        // GetUserProfile call fails
        userRepository.getUserProfile_result = Fail(error: UserRepositoryError.authProviderNotFound).asFuture()

        // Open the screen
        viewModel.inputs.onAppear.send()

        // Should show error alert
        XCTAssertEqual(showAlertTitleRecords.results, [.value(R.string.localizable.edit_positive_statement_edit_error())])
        XCTAssertEqual(showAlertMessageRecords.results, [.value(nil)])
        XCTAssertEqual(showAlertPrimaryActionTitleRecords.results, [.value(R.string.localizable.ok())])
    }

    func test_ifAUserOpensTheScreen_getUserProfileFails_andTheUserTapsOK__itShouldDismissTheScreen() {
        // GetUserProfile call fails
        userRepository.getUserProfile_result = Fail(error: UserRepositoryError.authProviderNotFound).asFuture()

        // Open the screen
        viewModel.inputs.onAppear.send()

        // Taps OK
        viewModel.outputs.showAlert?.primaryAction?.action?()

        // Should dismiss the screen
        XCTAssertEqual(router.dismiss_calledCount, 1)
    }

    func test_ifAUserOepnsTheScreen_andGetPositiveStatementFails__itShouldShowErrorAlert() {
        let showAlertTitleRecords = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.title).eraseToAnyPublisher())
        showAlertTitleRecords.clearResult()

        // GetUserProfile call fails
        userRepository.getUserProfile_result = Fail(error: UserRepositoryError.authProviderNotFound).asFuture()

        // Open the screen
        viewModel.inputs.onAppear.send()

        // Should show error alert
        XCTAssertEqual(showAlertTitleRecords.results, [.value(R.string.localizable.edit_positive_statement_edit_error())])
    }

    func test_ifTextFieldTextUpdated_withoutText__itShouldUpdateIsDoneButtonDisabledFalse__withLessThanOrEqualTo100Characters__itShouldUpdateTrue__andWithMoreThan100Characters__itShouldUpdateFalse() {
        let isDoneButtonDisabledRecords = TestRecord(
            publisher: viewModel.outputs.isDoneButtonDisabled.eraseToAnyPublisher())
        isDoneButtonDisabledRecords.clearResult() // Remove the initial record

        // The 1st input should not be recorded
        viewModel.bindings.textFieldText = "1"
        XCTAssertTrue(isDoneButtonDisabledRecords.results.isEmpty)

        // when textFieldText character count is 1, done button should be enabled
        viewModel.bindings.textFieldText = "a"
        XCTAssertEqual(isDoneButtonDisabledRecords.results, [
            .value(false)
        ])
        isDoneButtonDisabledRecords.clearResult()

        // when textFieldText character hasn't changed from the last input, isDoneButtonDisabled shouldn't output another result
        viewModel.bindings.textFieldText = "a"
        XCTAssertTrue(isDoneButtonDisabledRecords.results.isEmpty)
        isDoneButtonDisabledRecords.clearResult()

        // when textFieldText character count is 0, done button should be disabled
        viewModel.bindings.textFieldText = ""
        XCTAssertEqual(isDoneButtonDisabledRecords.results, [
            .value(true)
        ])
        isDoneButtonDisabledRecords.clearResult()

        // when textFieldText character count is 99, done button should be enabled
        viewModel.bindings.textFieldText = "99characters......................................................................................"
        XCTAssertEqual(isDoneButtonDisabledRecords.results, [
            .value(false)
        ])
        isDoneButtonDisabledRecords.clearResult()

        // when textFieldText character count is 100, done button should be enabled
        viewModel.bindings.textFieldText = "100characters......................................................................................"
        XCTAssertEqual(isDoneButtonDisabledRecords.results, [
            .value(false)
        ])
        isDoneButtonDisabledRecords.clearResult()

        // when textFieldText character count is 101, done button should be disabled
        viewModel.bindings.textFieldText = "101characters........................................................................................."
        XCTAssertEqual(isDoneButtonDisabledRecords.results, [
            .value(true)
        ])
    }

    func test_ifAUserTapsDoneButton__itShouldUpdatePositiveStatement_withPassingTheTextFieldValue_andUserIdFromGetUserProfile__andIfAllSucceeded__itShouldDismissTheView_andShouldUpdateIsProcessingStatus() {

        let positiveStatementId = "positiveStatementId"
        setupViewModel(positiveStatementId: positiveStatementId)

        let isProcessingRecorder = TestRecord(publisher: viewModel.outputs.$isProcessing.eraseToAnyPublisher())
        isProcessingRecorder.clearResult() // Remove the initial value

        // Setup UserProfile
        let userProfile = Profile(id: "This is User ID", name: "", email: "", imageUrl: nil)
        userRepository.getUserProfile_result = Just(userProfile).setFailureType(to: Error.self).asFuture()

        // Setup updatePositiveStatement response as succeed
        positiveStatementRepository.updatePositiveStatement_result = Just(())
            .setFailureType(to: Error.self).asFuture()

        // Input textField
        viewModel.bindings.textFieldText = "Update Positive Statement"

        // Taps done button
        viewModel.inputs.doneButtonDidTap.send()

        // Should update Positive Statement
        XCTAssertEqual(
            positiveStatementRepository.updatePositiveStatement_calledCount,
            1)
        // Should pass positiveStatementId
        XCTAssertEqual(
            positiveStatementRepository.updatePositiveStatement_positiveStatementId,
            positiveStatementId)
        // Should pass positiveStatement from textField
        XCTAssertEqual(
            positiveStatementRepository.updatePositiveStatement_positiveStatement,
            viewModel.bindings.textFieldText)
        // Should pass userId from GetUserProfile
        XCTAssertEqual(
            positiveStatementRepository.updatePositiveStatement_userId,
            userProfile.id)
        // Should dismiss view
        XCTAssertEqual(router.dismiss_calledCount, 1)
        // Should show and hide isProcessing status
        XCTAssertEqual(isProcessingRecorder.results, [.value(true), .value(false)])
    }

    func test_ifAUserTapsDoneButton_andGetUserProfileThrowsAnError__itShouldShowAlert_andShouldNotUpdatePositiveStatement_andShouldNotDismissTheView__andIfUserTapsDoneButtonAgain__itShouldCallGetUserProfileAgain_shouldShowAlertAgain_andShouldUpdateIsProcessingStatus() {

        let showAlertTitleRecorder = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.title).eraseToAnyPublisher())
        let showAlertMessageRecorder = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.message).eraseToAnyPublisher())
        let isProcessingRecorder = TestRecord(publisher: viewModel.outputs.$isProcessing.eraseToAnyPublisher())
        showAlertTitleRecorder.clearResult()
        showAlertMessageRecorder.clearResult()
        isProcessingRecorder.clearResult()

        // Setup UserProfile as throwing an error
        userRepository.getUserProfile_result = Fail(error: NSError()).asFuture()

        // Taps done button
        viewModel.inputs.doneButtonDidTap.send()

        // Should show an error alert
        XCTAssertEqual(showAlertTitleRecorder.results, [ .value(R.string.localizable.edit_positive_statement_edit_error())])
        XCTAssertEqual(showAlertMessageRecorder.results, [.value(nil)])
        showAlertTitleRecorder.clearResult()
        showAlertMessageRecorder.clearResult()

        // Should not update Positive Statement
        XCTAssertEqual(
            positiveStatementRepository.updatePositiveStatement_calledCount,
            0)
        // Should not dismiss view
        XCTAssertEqual(router.dismiss_calledCount, 0)
        // Should show and hide isProcessing status
        XCTAssertEqual(isProcessingRecorder.results, [.value(true), .value(false)])
        isProcessingRecorder.clearResult()

        // Taps done button again
        viewModel.inputs.doneButtonDidTap.send()

        // Should call userRepository.getUserProfile again
        XCTAssertEqual(userRepository.getUserProfile_calledCount, 2)

        // Should show an error alert again
        XCTAssertEqual(showAlertTitleRecorder.results, [ .value(R.string.localizable.edit_positive_statement_edit_error())])
        XCTAssertEqual(showAlertMessageRecorder.results, [.value(nil)])

        // Should show and hide isProcessing status again
        XCTAssertEqual(isProcessingRecorder.results, [.value(true), .value(false)])
    }

    func test_ifAUserTapsDoneButton_andUpdatePositiveStatementThrowsAnError__itShouldShowAlert_andShouldNotDismissTheView__andIfUserTapsDoneButtonAgain__itShouldCallUpdatePositiveStatmentAgain_shouldShowAlertAgain_andShouldUpdateIsProcessingStatus() {

        let showAlertTitleRecorder = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.title).eraseToAnyPublisher())
        let showAlertMessageRecorder = TestRecord(publisher: viewModel.outputs.$showAlert.map(\.?.message).eraseToAnyPublisher())
        let isProcessingRecorder = TestRecord(publisher: viewModel.outputs.$isProcessing.eraseToAnyPublisher())
        showAlertTitleRecorder.clearResult()
        showAlertMessageRecorder.clearResult()
        isProcessingRecorder.clearResult()

        // Setup UserProfile as succeed
        let userProfile = Profile(id: "", name: "", email: "", imageUrl: nil)
        userRepository.getUserProfile_result = Just(userProfile).setFailureType(to: Error.self).asFuture()

        // Setup updatePositiveStatement response as throwing an error
        positiveStatementRepository.updatePositiveStatement_result = Fail(error: NSError()).asFuture()

        // Taps done button
        viewModel.inputs.doneButtonDidTap.send()

        // Should show an error alert
        XCTAssertEqual(showAlertTitleRecorder.results, [ .value(R.string.localizable.edit_positive_statement_edit_error())])
        XCTAssertEqual(showAlertMessageRecorder.results, [.value(nil)])
        showAlertTitleRecorder.clearResult()
        showAlertMessageRecorder.clearResult()

        // Should not dismiss view
        XCTAssertEqual(router.dismiss_calledCount, 0)

        // Should show and hide isProcessing status
        XCTAssertEqual(isProcessingRecorder.results, [.value(true), .value(false)])
        isProcessingRecorder.clearResult()

        // Taps done button again
        viewModel.inputs.doneButtonDidTap.send()

        // Should call userRepository.getUserProfile again
        XCTAssertEqual(positiveStatementRepository.updatePositiveStatement_calledCount, 2)

        // Should show an error alert again
        XCTAssertEqual(showAlertTitleRecorder.results, [ .value(R.string.localizable.edit_positive_statement_edit_error())])
        XCTAssertEqual(showAlertMessageRecorder.results, [.value(nil)])

        // Should show and hide isProcessing status again
        XCTAssertEqual(isProcessingRecorder.results, [.value(true), .value(false)])
    }
}

private class MockEditPositiveStatementRouter: MockRouter, EditPositiveStatementRouter {
    var dismiss_calledCount = 0
    func dismiss() {
        dismiss_calledCount += 1
    }
}
