//
//  BottomHalfSheetMenuViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2021/10/16.
//  Copyright © 2021 Aika Yamada. All rights reserved.
//

import UIKit
import Combine
import FloatingPanel

private let scrollViewTopMargin = CGFloat(16)

private let backgroundViewAlpha = CGFloat(0.5)

private let removalInteractionVelocityThreshold = CGFloat(2)

private let halfSheetCornerRadius = CGFloat(12)

class BottomHalfSheetMenuViewController: UIViewController {

    let scrollView = UIScrollView()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }()

    // Public Publisher
    let itemDidTap = PassthroughSubject<BottomHalfSheetMenuItem, Never>()
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupStackView()
    }
}

// MARK: - Private
private extension BottomHalfSheetMenuViewController {
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

    func setupStackView() {
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor),
            stackView.leftAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leftAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
            stackView.rightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.rightAnchor)
        ])
    }

    func setupMenu(menu: [BottomHalfSheetMenuItem]) {
        menu.forEach { menuItem in
            let itemView = BottomHalfSheetMenuItemView.instanceFromNib()
            itemView.bind(item: menuItem)
            itemView.viewDidTap
                .subscribe(itemDidTap)
                .store(in: &cancellables)

            stackView.addArrangedSubview(itemView)
        }
    }
}

// MARK: - Properties
private extension BottomHalfSheetMenuViewController {
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

// MARK: - FloatingPanelController Public Extension
extension FloatingPanelController {
    static func createBottomHalfSheetMenu(menu: [BottomHalfSheetMenuItem]) -> FloatingPanelController {
        let floatingPanelController = FloatingPanelController()
        let bottomHalfSheetMenuViewController = BottomHalfSheetMenuViewController()
        bottomHalfSheetMenuViewController.setupMenu(menu: menu)

        floatingPanelController.layout = BottomHalfSheetMenuLayout(layoutGuide: bottomHalfSheetMenuViewController.layoutGuide)

        let behavior = BottomHalfSheetMenuBehavior()
        behavior.removalInteractionVelocityThreshold = removalInteractionVelocityThreshold
        floatingPanelController.behavior = behavior

        let appearance = SurfaceAppearance()
        appearance.cornerRadius = halfSheetCornerRadius
        floatingPanelController.surfaceView.appearance = appearance

        floatingPanelController.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        floatingPanelController.isRemovalInteractionEnabled = true

        floatingPanelController.set(contentViewController: bottomHalfSheetMenuViewController)
        floatingPanelController.track(scrollView: bottomHalfSheetMenuViewController.scrollView)
        return floatingPanelController
    }

    var contentBottomHalfSheetMenuViewController: BottomHalfSheetMenuViewController? {
        contentViewController as? BottomHalfSheetMenuViewController
    }
}

// MARK: - FloatingPanel Properties
private extension FloatingPanelController {
    class BottomHalfSheetMenuBehavior: FloatingPanelDefaultBehavior {
        override func allowsRubberBanding(for edge: UIRectEdge) -> Bool {
            return true
        }
    }

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
}
