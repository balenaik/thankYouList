//
//  BottomHalfSheetDatePickerViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2022/05/10.
//  Copyright © 2022 Aika Yamada. All rights reserved.
//

import Foundation
import FloatingPanel

private let navigationBarFontSize = CGFloat(17)
private let navigationBarTopMargin = CGFloat(16)

private let doneButtonHorizontalMargin = CGFloat(24)
private let doneButtonBottomMargin = CGFloat(16)
private let doneButtonCornerRadius = CGFloat(16)
private let doneButtonFontSize = CGFloat(17)
private let doneButtonHeight = CGFloat(44)

private let backgroundViewAlpha = CGFloat(0.5)

private let removalInteractionVelocityThreshold = CGFloat(2)

private let halfSheetCornerRadius = CGFloat(12)

protocol BottomHalfSheetDatePickerViewControllerDelegate: class {
    func bottomHalfSheetDatePickerViewControllerDidTapDone(date: Date)
}

class BottomHalfSheetDatePickerViewController: UIViewController {

    private let navigationBar = UINavigationBar()
    private let scrollView = UIScrollView()
    private let datePicker = UIDatePicker()

    weak var delegate: BottomHalfSheetDatePickerViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupScrollView()
        setupDatePicker()
        setupDoneButton()
    }
}

// MARK: - Private
private extension BottomHalfSheetDatePickerViewController {
    func setupNavigation() {
        view.addSubview(navigationBar)
        // Remove shadow
        navigationBar.setBackgroundImage(UIImage(),
                                         for: UIBarPosition.any,
                                         barMetrics: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()

        let navigationItem = UINavigationItem()
        navigationItem.title = R.string.localizable.date()
        navigationBar.setItems([navigationItem], animated: true)
        navigationBar.titleTextAttributes = [
            .font: UIFont.boldAvenir(ofSize: navigationBarFontSize)
        ]

        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: navigationBarTopMargin),
            navigationBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }

    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: navigationBar.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }

    func setupDatePicker() {
        scrollView.addSubview(datePicker)
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor),
            datePicker.leftAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leftAnchor),
            datePicker.rightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.rightAnchor)
        ])
    }

    func setupDoneButton() {
        let doneButton = UIButton()
        view.addSubview(doneButton)
        doneButton.setTitle(R.string.localizable.done(), for: .normal)
        doneButton.setBackgroundColor(color: .primary500, for: .normal)
        doneButton.setBackgroundColor(color: UIColor.primary500.darken(), for: .highlighted)
        doneButton.layer.cornerRadius = doneButtonCornerRadius
        doneButton.titleLabel?.font = UIFont.boldAvenir(ofSize: doneButtonFontSize)
        doneButton.clipsToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonDidTap(_:)), for: .touchUpInside)

        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: datePicker.safeAreaLayoutGuide.bottomAnchor),
            doneButton.leftAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leftAnchor,
                                             constant: doneButtonHorizontalMargin),
            doneButton.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor, constant: -doneButtonBottomMargin),
            doneButton.rightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.rightAnchor,
                                              constant: -doneButtonHorizontalMargin),
            doneButton.heightAnchor.constraint(equalToConstant: doneButtonHeight)
        ])
    }

    @objc func doneButtonDidTap(_ sender: UIButton) {
        delegate?.bottomHalfSheetDatePickerViewControllerDidTapDone(date: datePicker.date)
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
        date: Date,
        bottomSheetDelegate: BottomHalfSheetDatePickerViewControllerDelegate?) -> UIViewController {
        let floatingPanelController = FloatingPanelController()
        let bottomHalfSheetViewController = BottomHalfSheetDatePickerViewController()
        bottomHalfSheetViewController.delegate = bottomSheetDelegate
        bottomHalfSheetViewController.setupDate(date)

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

    func setupDate(_ date: Date) {
        datePicker.date = date
    }
}
