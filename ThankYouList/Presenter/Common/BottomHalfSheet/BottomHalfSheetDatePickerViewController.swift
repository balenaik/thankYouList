//
//  BottomHalfSheetDatePickerViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2022/05/10.
//  Copyright © 2022 Aika Yamada. All rights reserved.
//

import Foundation
import FloatingPanel

private let scrollViewTopMargin = CGFloat(16)

private let backgroundViewAlpha = CGFloat(0.5)

private let removalInteractionVelocityThreshold = CGFloat(2)

private let halfSheetCornerRadius = CGFloat(12)

protocol BottomHalfSheetDatePickerViewControllerDelegate: class {
    func bottomHalfSheetDatePickerViewControllerDidTapDone(date: Date)
}

class BottomHalfSheetDatePickerViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let datePicker = UIDatePicker()

    weak var delegate: BottomHalfSheetDatePickerViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupDatePicker()
    }
}

// MARK: - Private
private extension BottomHalfSheetDatePickerViewController {
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: scrollViewTopMargin),
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }

    func setupDatePicker() {
        scrollView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor),
            datePicker.leftAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leftAnchor),
            datePicker.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
            datePicker.rightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.rightAnchor)
        ])
    }
}

// MARK: - FloatingPanel Properties
private extension BottomHalfSheetDatePickerViewController {
    class BottomHalfSheetLayout: FloatingPanelBottomLayout {
        init(layoutGuide: UILayoutGuide) {
            self.layoutGuide = layoutGuide
        }
        private let layoutGuide: UILayoutGuide
        override var initialState: FloatingPanelState { .tip }
        override var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
            return [
                .tip: FloatingPanelAdaptiveLayoutAnchor(fractionalOffset: 0,
                                                        contentLayout: layoutGuide,
                                                        referenceGuide: .safeArea)
            ]
        }

        override func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
            return backgroundViewAlpha
        }
    }

    class BottomHalfSheetDatePickerBehavior: FloatingPanelDefaultBehavior {
        override func allowsRubberBanding(for edge: UIRectEdge) -> Bool {
            return true
        }
    }

    var layoutGuide: UILayoutGuide {
        let layoutGuide = UILayoutGuide()
        view.addLayoutGuide(layoutGuide)

        NSLayoutConstraint.activate([
            layoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            layoutGuide.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            layoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            layoutGuide.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
        return layoutGuide
    }
}

// MARK: - Public
extension BottomHalfSheetDatePickerViewController {
    static func createViewController(
        bottomSheetDelegate: BottomHalfSheetDatePickerViewControllerDelegate?) -> UIViewController {
        let floatingPanelController = FloatingPanelController()
        let bottomHalfSheetViewController = BottomHalfSheetDatePickerViewController()
        bottomHalfSheetViewController.delegate = bottomSheetDelegate

        floatingPanelController.layout = BottomHalfSheetLayout(layoutGuide: bottomHalfSheetViewController.layoutGuide)

        let behavior = BottomHalfSheetDatePickerBehavior()
        behavior.removalInteractionVelocityThreshold = removalInteractionVelocityThreshold
        floatingPanelController.behavior = behavior

        let appearance = SurfaceAppearance()
        appearance.cornerRadius = halfSheetCornerRadius
        floatingPanelController.surfaceView.appearance = appearance

        floatingPanelController.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        floatingPanelController.isRemovalInteractionEnabled = true

        floatingPanelController.set(contentViewController: bottomHalfSheetViewController)
        floatingPanelController.track(scrollView: bottomHalfSheetViewController.scrollView)
        return floatingPanelController
    }
}
