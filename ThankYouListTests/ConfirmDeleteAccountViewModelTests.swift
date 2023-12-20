//
//  ConfirmDeleteAccountViewModelTests.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2023/04/01.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import XCTest
import Combine
import EntwineTest
@testable import ThankYouList

final class ConfirmDeleteAccountViewModelTests: XCTestCase {

    private var viewModel: ConfirmDeleteAccountViewModel!
    private var userRepository: MockUserRepository!
    private var analyticsManager: MockAnalyticsManager!
    private var router: MockConfirmDeleteAccouuntRouter!

    private var scheduler: TestScheduler!

    override func setUp() {
        userRepository = MockUserRepository()
        analyticsManager = MockAnalyticsManager()
        router = MockConfirmDeleteAccouuntRouter()
        viewModel = ConfirmDeleteAccountViewModel(userRepository: userRepository,
                                                  analyticsManager: analyticsManager,
                                                  router: router)
        scheduler = TestScheduler()
    }

    func test_ifTheUserOpensTheScreen_whenHisEmailIsRegistered__itShouldShowHisEmailAsTextFieldPlaceHolder() {
        let mockEmail = "mock@email.com"
        userRepository.getUserProfile_result =
            Just(Profile(id: "", name: "", email: mockEmail, imageUrl: nil))
            .setFailureType(to: Error.self).asFuture()

        let emailTextFieldPlaceHolder = scheduler.createObserver(from: viewModel.outputs.emailTextFieldPlaceHolder)

        scheduler.schedule(after: 10) {
            self.viewModel.inputs.onAppear.send(())
        }

        scheduler.resume()

        XCTAssertEqual(emailTextFieldPlaceHolder.recordedOutput, [
            (0, .subscription),
            (0, .input("")),
            (10, .input(mockEmail))
        ])
    }

    func test_ifTheUserOpensTheScreen_whenHisEmailIsEmpty__itShouldShowErrorAlert__andWhenOkButtonTapped__itShouldDismissScreen() {
        userRepository.getUserProfile_result =
            Just(Profile(id: "", name: "", email: "", imageUrl: nil))
            .setFailureType(to: Error.self).asFuture()

        let alertItemTitle = scheduler
            .createObserver(from: viewModel.bindings.$alertItem.map(\.?.title))
        let alertItemMessage = scheduler
            .createObserver(from: viewModel.bindings.$alertItem.map(\.?.message))

        scheduler.schedule(after: 10) {
            self.viewModel.inputs.onAppear.send(())
        }
        scheduler.schedule(after: 20) {
            XCTAssertEqual(self.router.dismiss_calledCount, 0)
            self.viewModel.bindings.alertItem?.okAction()
        }

        scheduler.resume()

        XCTAssertEqual(alertItemTitle.recordedOutput.remove1stInputResultIfNecessary(), [
            (0, .subscription),
            (10, .input(R.string.localizable.confirm_delete_account_error_title()))
        ])
        XCTAssertEqual(alertItemMessage.recordedOutput.remove1stInputResultIfNecessary(), [
            (0, .subscription),
            (10, .input(R.string.localizable.confirm_delete_account_error_message()))
        ])
        XCTAssertEqual(router.dismiss_calledCount, 1)
    }

    func test_ifTheUserOpensTheScreen_whenHisEmailIsRegistered_inputOtherThanHisEmailOnTextField_andTapDeleteButton__itShouldShowErrorAlert() {
        let userEmail = "user@email.com"
        userRepository.getUserProfile_result =
            Just(Profile(id: "", name: "", email: userEmail, imageUrl: nil))
            .setFailureType(to: Error.self).asFuture()

        let alertItemTitle = scheduler
            .createObserver(from: viewModel.bindings.$alertItem.map(\.?.title))
        let alertItemMessage = scheduler
            .createObserver(from: viewModel.bindings.$alertItem.map(\.?.message))

        scheduler.schedule(after: 10) {
            self.viewModel.inputs.onAppear.send(())
        }
        scheduler.schedule(after: 20) {
            self.viewModel.bindings.emailTextFieldText = userEmail + "abc"
            self.viewModel.inputs.deleteAccountButtonDidTap.send(())
        }
        scheduler.schedule(after: 30) {
            self.viewModel.bindings.emailTextFieldText = "user@email.co"
            self.viewModel.inputs.deleteAccountButtonDidTap.send(())
        }
        scheduler.schedule(after: 40) {
            self.viewModel.bindings.emailTextFieldText = "ser@email.com"
            self.viewModel.inputs.deleteAccountButtonDidTap.send(())
        }
        scheduler.schedule(after: 50) {
            self.viewModel.bindings.emailTextFieldText = "abc" + userEmail
            self.viewModel.inputs.deleteAccountButtonDidTap.send(())
        }

        scheduler.resume()

        XCTAssertEqual(alertItemTitle.recordedOutput.remove1stInputResultIfNecessary(), [
            (0, .subscription),
            (20, .input(R.string.localizable.confirm_delete_account_email_not_match_title())),
            (30, .input(R.string.localizable.confirm_delete_account_email_not_match_title())),
            (40, .input(R.string.localizable.confirm_delete_account_email_not_match_title())),
            (50, .input(R.string.localizable.confirm_delete_account_email_not_match_title()))
        ])
        XCTAssertEqual(alertItemMessage.recordedOutput.remove1stInputResultIfNecessary(), [
            (0, .subscription),
            (20, .input(R.string.localizable.confirm_delete_account_email_not_match_message(userEmail))),
            (30, .input(R.string.localizable.confirm_delete_account_email_not_match_message(userEmail))),
            (40, .input(R.string.localizable.confirm_delete_account_email_not_match_message(userEmail))),
            (50, .input(R.string.localizable.confirm_delete_account_email_not_match_message(userEmail)))
        ])
    }

    func test_ifTheUserOpensTheScreen_whenHisEmailIsRegistered_inputHisEmailOnTextField_tapDeleteButton_andDeleteSucceeded__itShouldShowAlert__andWhenOkButtonTapped__itShouldSwitchToLogin() {
        let userEmail = "user@email.com"
        userRepository.getUserProfile_result =
            Just(Profile(id: "", name: "", email: userEmail, imageUrl: nil))
            .setFailureType(to: Error.self).asFuture()
        userRepository.deleteAccount_result = Just(())
            .setFailureType(to: Error.self).asFuture()

        let alertItemTitle = scheduler
            .createObserver(from: viewModel.bindings.$alertItem.map(\.?.title))
        let alertItemMessage = scheduler
            .createObserver(from: viewModel.bindings.$alertItem.map(\.?.message))

        scheduler.schedule(after: 10) {
            self.viewModel.inputs.onAppear.send(())
        }
        scheduler.schedule(after: 20) {
            self.viewModel.bindings.emailTextFieldText = userEmail
            self.viewModel.inputs.deleteAccountButtonDidTap.send(())
        }
        scheduler.schedule(after: 30) {
            XCTAssertEqual(self.router.switchToLogin_calledCount, 0)
            self.viewModel.bindings.alertItem?.okAction()
        }

        scheduler.resume()

        XCTAssertEqual(alertItemTitle.recordedOutput.remove1stInputResultIfNecessary(), [
            (0, .subscription),
            (20, .input(R.string.localizable.confirm_delete_account_completed_title()))
        ])
        XCTAssertEqual(alertItemMessage.recordedOutput.remove1stInputResultIfNecessary(), [
            (0, .subscription),
            (20, .input(nil))
        ])
        XCTAssertEqual(self.router.switchToLogin_calledCount, 1)
    }

    func test_ifTheUserOpensTheScreen_whenHisEmailIsRegistered_inputHisEmailOnTextField_tapDeleteButton_andDeleteSucceeded__itShouldPostAnalyticsEvent() {
        let userEmail = "user@email.com"
        let userId = "userId"
        userRepository.getUserProfile_result =
            Just(Profile(id: userId, name: "", email: userEmail, imageUrl: nil))
            .setFailureType(to: Error.self).asFuture()
        userRepository.deleteAccount_result = Just(())
            .setFailureType(to: Error.self).asFuture()

        scheduler.schedule(after: 10) {
            self.viewModel.inputs.onAppear.send(())
        }
        scheduler.schedule(after: 20) {
            self.viewModel.bindings.emailTextFieldText = userEmail
            self.viewModel.inputs.deleteAccountButtonDidTap.send(())
        }

        scheduler.resume()

        XCTAssertEqual(analyticsManager.loggedEvent.count, 1)
        XCTAssertEqual(analyticsManager.loggedEvent.first?.eventName, AnalyticsEventConst.deleteAccount)
        XCTAssertEqual(analyticsManager.loggedEvent.first?.userId, userId)
    }

    func test_ifTheUserOpensTheScreen_whenHisEmailIsRegistered_inputHisEmailOnTextField_tapDeleteButton_andDeleteFailed__itShouldShowAlert() {
        let userEmail = "user@email.com"
        userRepository.getUserProfile_result =
            Just(Profile(id: "", name: "", email: userEmail, imageUrl: nil))
            .setFailureType(to: Error.self).asFuture()
        userRepository.deleteAccount_result = Fail(error: UserRepositoryError.authProviderNotFound)
            .asFuture()

        let alertItemTitle = scheduler
            .createObserver(from: viewModel.bindings.$alertItem.map(\.?.title))
        let alertItemMessage = scheduler
            .createObserver(from: viewModel.bindings.$alertItem.map(\.?.message))

        scheduler.schedule(after: 10) {
            self.viewModel.inputs.onAppear.send(())
        }
        scheduler.schedule(after: 20) {
            self.viewModel.bindings.emailTextFieldText = userEmail
            self.viewModel.inputs.deleteAccountButtonDidTap.send(())
        }

        scheduler.resume()

        XCTAssertEqual(alertItemTitle.recordedOutput.remove1stInputResultIfNecessary(), [
            (0, .subscription),
            (20, .input(R.string.localizable.confirm_delete_account_error_title()))
        ])
        XCTAssertEqual(alertItemMessage.recordedOutput.remove1stInputResultIfNecessary(), [
            (0, .subscription),
            (20, .input(R.string.localizable.try_again_later_message()))
        ])
    }

    func test_ifTheUserOpensTheScreen_whenHisEmailIsRegistered_andInputHisEmailOnTextField__itShouldEnableDeleteAccountButton_onlyWhenTheInputEmailIsValid_otherwiseDisableTheButton() {
        userRepository.getUserProfile_result =
            Just(Profile(id: "", name: "", email: "user@email.com", imageUrl: nil))
            .setFailureType(to: Error.self).asFuture()

        let isDeleteAccountButtonDisabled = scheduler
            .createObserver(from: viewModel.outputs.$isDeleteAccountButtonDisabled)

        scheduler.schedule(after: 10) {
            self.viewModel.inputs.onAppear.send(())
        }
        scheduler.schedule(after: 20) {
            self.viewModel.bindings.emailTextFieldText = "abc"
        }
        scheduler.schedule(after: 30) {
            self.viewModel.bindings.emailTextFieldText = "123"
        }
        scheduler.schedule(after: 40) {
            self.viewModel.bindings.emailTextFieldText = "asd@aaa"
        }
        scheduler.schedule(after: 50) {
            self.viewModel.bindings.emailTextFieldText = "aaa.acs"
        }
        scheduler.schedule(after: 60) {
            self.viewModel.bindings.emailTextFieldText = "asd@aaa.acs"
        }

        scheduler.resume()

        XCTAssertEqual(isDeleteAccountButtonDisabled.recordedOutput.remove1stInputResultIfNecessary(), [
            (0, .subscription),
            (20, .input(true)),
            (30, .input(true)),
            (40, .input(true)),
            (50, .input(true)),
            (60, .input(false))
        ])
    }
}

private extension TestSequence {
    /// To remove the 1st input result
    func remove1stInputResultIfNecessary() -> TestSequence<Input, Failure> {
        let index = firstIndex { output in
            switch output.1 {
            case .input: return true
            default: return false
            }
        }
        guard let index = index else { return self }
        var outputs = self
        outputs.remove(at: index)
        return TestSequence(outputs)
    }
}

private class MockConfirmDeleteAccouuntRouter: ConfirmDeleteAccountRouter {
    var dismiss_calledCount = 0
    func dismiss() {
        dismiss_calledCount += 1
    }

    var switchToLogin_calledCount = 0
    func switchToLogin() {
        switchToLogin_calledCount += 1
    }
}
