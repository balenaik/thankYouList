//
//  AddPositiveStatementViewModelTests.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2024/03/21.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import XCTest
import Combine
import CombineSchedulers
@testable import ThankYouList

final class AddPositiveStatementViewModelTests: XCTestCase {

    private var viewModel: AddPositiveStatementViewModel!

    override func setUp() {
        viewModel = AddPositiveStatementViewModel()
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
            .value(R.string.localizable.add_positive_statement_character_count_text("1", maxCountString))
        ])
        characterCounterTextRecords.clearResult()

        viewModel.bindings.textFieldText = "abcdefghi"
        XCTAssertEqual(characterCounterTextRecords.results, [
            .value(R.string.localizable.add_positive_statement_character_count_text("9", maxCountString))
        ])
        characterCounterTextRecords.clearResult()

        viewModel.bindings.textFieldText = "abcdefghiあいうえお今晩は😀\n！！"
        XCTAssertEqual(characterCounterTextRecords.results, [
            .value(R.string.localizable.add_positive_statement_character_count_text("21", maxCountString))
        ])
    }
}
