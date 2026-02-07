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

    func test_ifAUserOpensTheScreen__itShouldCallGetUserProfile() {
        // Open the screen once
        viewModel.inputs.viewDidLoad.send()
        // It should call getUserProfile once
        XCTAssertEqual(userRepository.getUserProfile_calledCount, 1)
    }

    func test_ifAUserOpensTheScreen__itShouldSubscribeThankYouList_andPassUserId() {
        // Set a mock result to return userId on getUserProfile
        let userId = "userId"
        userRepository.getUserProfile_result = Just(Profile(id: userId, name: "", email: "", imageUrl: nil)).setFailureType(to: Error.self).asFuture()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // It should call subscribeThankYouList
        XCTAssertEqual(thankYouRepository.subscribeThankYouList_calledCount, 1)
        // It should pass userId
        XCTAssertEqual(thankYouRepository.subscribeThankYouList_userId, userId)
    }

    func test_ifAUserOpensTheScreen_andGetUserProfileFails__itShouldPresentErrorAlert() {
        // Set an error result on getUserProfile
        userRepository.getUserProfile_result = Fail(error: UserRepositoryError.currentUserNotExist).asFuture()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // It should present an error alert
        XCTAssertEqual(router.presentAlert_calledCount, 1)
        XCTAssertEqual(router.presentAlert_title, R.string.localizable.thank_you_list_load_error_title())
        XCTAssertEqual(router.presentAlert_message, R.string.localizable.thank_you_list_load_error_message())
    }

    func test_ifAUserOpensTheScreen_andSubscribeThankYouListEmitsError__itShouldPresentErrorAlert() {
        // Set subscribeThankYouList to emit an error case
        thankYouRepository.subscribeThankYouList_result = Just(.error(ThankYouRepositoryError.snapshotNotFound)).eraseToAnyPublisher()

        // Open the screen
        viewModel.inputs.viewDidLoad.send()

        // It should present an error alert
        XCTAssertEqual(router.presentAlert_calledCount, 1)
        XCTAssertEqual(router.presentAlert_title, R.string.localizable.thank_you_list_load_error_title())
        XCTAssertEqual(router.presentAlert_message, R.string.localizable.thank_you_list_load_error_message())
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

    func test_ifUserTapsBottomHalfSheetMenu_thatHasDeleteValue__itShouldDismissPresentedView_andPresentAlert() {
        let dismissPresentedViewRecords = TestRecord(
            publisher: viewModel.outputs.dismissPresentedView.map { "" }.eraseToAnyPublisher())

        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.delete.rawValue,
                  id: "thankYouId")
        )
        scheduler.advance(by: .milliseconds(100))
        XCTAssertEqual(dismissPresentedViewRecords.results, [.value("")])
        XCTAssertEqual(router.presentAlert_calledCount, 1)
        XCTAssertEqual(router.presentAlert_title, R.string.localizable.deleteThankYou())
        XCTAssertEqual(router.presentAlert_message, R.string.localizable.areYouSureYouWantToDeleteThisThankYou())
        let firstAction = router.presentAlert_actions?.first
        XCTAssertEqual(firstAction?.title, R.string.localizable.delete())
        XCTAssertEqual(firstAction?.style, .destructive)
        let secondAction = router.presentAlert_actions?[1]
        XCTAssertEqual(secondAction?.title, R.string.localizable.cancel())
        XCTAssertEqual(secondAction?.style, .cancel)
    }

    func test_ifUserTapsBottomHalfSheetMenu_thatHasDeleteValue_andTapsDeleteButton__itShouldCallDeleteThankYou__andEvenIfTheFirstTryFails__itShouldCallDeleteThankYouAgain() {

        // Tap delete button on menu
        viewModel.inputs.bottomHalfSheetMenuDidTap.send(
            .init(title: "",
                  image: nil,
                  rawValue: ThankYouCellTapMenu.delete.rawValue,
                  id: "thankYouId")
        )
        scheduler.advance(by: .milliseconds(100))

        let deleteAction = router.presentAlert_actions?.first

        // Set delete thank you first result as failed
        thankYouRepository.deleteThankYou_result = Fail(error: NSError()).asFuture()

        // Tap delete button on confirmation halfsheet #1
        deleteAction?.action!()

        // deleteThankYou should be called once
        XCTAssertEqual(thankYouRepository.deleteThankYou_calledCount, 1)

        // Set delete thank you first result as success
        thankYouRepository.deleteThankYou_result = Just(()).setFailureType(to: Error.self).asFuture()

        // Tap delete button on confirmation halfsheet #2
        deleteAction?.action!()

        // deleteThankYou should be called twice
        XCTAssertEqual(thankYouRepository.deleteThankYou_calledCount, 2)
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
