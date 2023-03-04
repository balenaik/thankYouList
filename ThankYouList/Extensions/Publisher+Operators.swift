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

    func shareReplay(_ bufferSize: Int) -> AnyPublisher<Output, Failure> {
        return multicast(subject: ReplaySubject(bufferSize)).autoconnect().eraseToAnyPublisher()
    }

    func asResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        return map(Result.success)
            .catch { Just(Result.failure($0)) }
            .eraseToAnyPublisher()
    }

    func values<S, F: Error>()
    -> AnyPublisher<S, Never> where Output == Result<S, F>, Failure == Never {
        return filter { result in
            switch result {
            case .success: return true
            case .failure: return false
            }
        }
        .flatMap { result -> AnyPublisher<S, Never> in
            switch result {
            case .success(let value):
                return Just(value).eraseToAnyPublisher()
            case .failure:
                return Empty().eraseToAnyPublisher() // Should not come
            }
        }.eraseToAnyPublisher()
    }

    func errors<S, F: Error>()
    -> AnyPublisher<F, Never> where Output == Result<S, F>, Failure == Never {
        return filter { result in
            switch result {
            case .success: return false
            case .failure: return true
            }
        }
        .flatMap { (result) -> AnyPublisher<F, Never> in
            switch result {
            case .success:
                return Empty().eraseToAnyPublisher() // Should not come
            case .failure(let error):
                return Just(error).eraseToAnyPublisher()
            }
        }.eraseToAnyPublisher()
    }
}
