//
//  TestRecord.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2023/12/17.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Combine
@testable import ThankYouList

enum TestResult<Output: Equatable, Failure: Equatable>: Equatable {
    case value(Output)
    case error(Failure)

    static func == (lhs: TestResult<Output, Failure>, rhs: TestResult<Output, Failure>) -> Bool {
        switch (lhs, rhs) {
        case (.value(let lhsValue), .value(let rhsValue)):
            return lhsValue == rhsValue
        case (.error(let lhsValue), .error(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

class TestRecord<Output: Equatable, Failure: Error & Equatable> {
    var results =  [TestResult<Output, Failure>]()
    private var cancellables = Set<AnyCancellable>()

    init(publisher: AnyPublisher<Output, Failure>) {
        publisher.asResult()
            .sink { [weak self] result in
                switch result {
                case .success(let output):
                    self?.results.append(.value(output))
                case .failure(let error):
                    self?.results.append(.error(error))
                }
            }
            .store(in: &cancellables)
    }

    func clearResult() {
        results = []
    }
}
