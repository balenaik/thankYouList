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
        Publishers.CombineLatest(self.map { ($0, UUID()) }.map { (value: $0, date: Date()) },
                                 other.map { (value: $0, date: Date()) })
            .scan(nil as ((Self.Output, UUID)?, Source.Output)?, { accumulator, value in
                if accumulator == nil,
                   value.0.date < value.1.date {
                    // When the first events come in the order of self -> other,
                    // we want to prevent sending a new event
                    return (nil, value.1.value)
                } else {
                    return (value.0.value, value.1.value)
                }
            })
            .compactMap { event -> ((Self.Output, UUID), Source.Output)? in
                guard let event = event,
                      let selfEvent = event.0 else { return nil }
                return (selfEvent, event.1)
            }
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

    func sendEvent<S>(_ output: S, to subject: PassthroughSubject<S, Never>) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveOutput: { _ in subject.send(output) })
    }

    func withUnretained<T: AnyObject>(_ object: T) -> Publishers.CompactMap<Self, (T, Self.Output)> {
        compactMap { [weak object] output in
            guard let object = object else {
                return nil
            }
            return (object, output)
        }
    }
}
