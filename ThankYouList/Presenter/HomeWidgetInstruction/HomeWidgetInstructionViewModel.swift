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
    }
}

extension HomeWidgetInstructionViewModel {
    class Inputs {
    }

    class Outputs: ObservableObject {
    }
}
