//
//  HomeWidgetInstructionViewModel.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/07/14.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine

enum HomeWidgetinstructionPage {
    case page1
    case page2
    case page3

    enum NavigationType {
        case modal
        case push
    }

    var navigationType: NavigationType {
        switch self {
        case .page1: return .modal
        case .page2, .page3: return .push
        }
    }

    var imageName: String {
        switch self {
        case .page1: R.image.imageHomeWidgetInstructionPage1.name
        case .page2: R.image.imageHomeWidgetInstructionPage2.name
        case .page3: R.image.imageHomeWidgetInstructionPage3.name
        }
    }
}

protocol HomeWidgetinstructionRouter: Router {
    func pushToPage2()
    func pushToPage3()
    func dismiss()
}

class HomeWidgetInstructionViewModel: ObservableObject {

    let inputs = Inputs()
    @Published var outputs = Outputs()

    private var cancellable = Set<AnyCancellable>()
    private let page: HomeWidgetinstructionPage
    private let router: HomeWidgetinstructionRouter?

    init(page: HomeWidgetinstructionPage, router: HomeWidgetinstructionRouter?) {
        self.page = page
        self.router = router
        bind()
    }
}

private extension HomeWidgetInstructionViewModel {
    func bind() {
        inputs.onAppear
            .first()
            .sink { [outputs, page] in
                outputs.imageName = page.imageName
            }
            .store(in: &cancellable)

        inputs.cancelButtonDidTap
            .sink { [router] in
                router?.dismiss()
            }
            .store(in: &cancellable)
    }
}

extension HomeWidgetInstructionViewModel {
    class Inputs {
        let onAppear = PassthroughSubject<Void, Never>()
        let cancelButtonDidTap = PassthroughSubject<Void, Never>()
    }

    class Outputs: ObservableObject {
        @Published var imageName = ""
    }
}
