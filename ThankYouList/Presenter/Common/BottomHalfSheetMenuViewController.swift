//
//  BottomHalfSheetMenuViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2021/10/16.
//  Copyright © 2021 Aika Yamada. All rights reserved.
//

import UIKit
import FloatingPanel

private let stackViewTopMargin = CGFloat(20)

private let backgroundViewAlpha = CGFloat(0.5)

private let removalInteractionVelocityThreshold = CGFloat(2)

class BottomHalfSheetMenuViewController: UIViewController {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackView()
    }
}

// MARK: - Private
private extension BottomHalfSheetMenuViewController {
    func setupStackView() {
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: stackViewTopMargin),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
}

// MARK: - FloatingPanel Properties
private extension BottomHalfSheetMenuViewController {
    class BottomHalfSheetMenuLayout: FloatingPanelBottomLayout {
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

    class BottomHalfSheetMenuBehavior: FloatingPanelDefaultBehavior {
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
extension BottomHalfSheetMenuViewController {
    static func createViewController() -> UIViewController {
        let floatingPanelController = FloatingPanelController()
        let bottomHalfSheetMenuViewController = BottomHalfSheetMenuViewController()

        floatingPanelController.layout = BottomHalfSheetMenuLayout(layoutGuide: bottomHalfSheetMenuViewController.layoutGuide)

        let behavior = BottomHalfSheetMenuBehavior()
        behavior.removalInteractionVelocityThreshold = removalInteractionVelocityThreshold
        floatingPanelController.behavior = behavior

        floatingPanelController.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        floatingPanelController.isRemovalInteractionEnabled = true

        floatingPanelController.set(contentViewController: bottomHalfSheetMenuViewController)
        return floatingPanelController
    }
}

// MARK: - BottomHalfSheetMenuButton
private class BottomHalfSheetMenuButton: UIButton {

}
