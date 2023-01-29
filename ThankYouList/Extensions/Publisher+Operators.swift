//
//  Publisher+Operators.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2023/01/22.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Combine
import Foundation

extension Publisher {
    func withLatestFrom<Source: Publisher, Result>(
        _ other: Source,
        resultSelector: @escaping (Output, Source.Output) -> Result)
    -> AnyPublisher<Result, Failure> where Source.Failure == Failure {
        Publishers.CombineLatest(self.map { ($0, UUID()) },
                                 other)
            .removeDuplicates(by: { prev, current in
                prev.0.1 == current.0.1
            })
            .map { ($0.0, $1) }
            .map(resultSelector)
            .eraseToAnyPublisher()
    }
}
