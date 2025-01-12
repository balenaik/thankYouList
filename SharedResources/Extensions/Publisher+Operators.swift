//
//  Publisher+Operators.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/11/30.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine

public extension Publisher {
    func asFuture() -> Future<Output, Failure> {
        return Future { promise in
            var ticket: AnyCancellable?
            ticket = self.sink(
                receiveCompletion: {
                    ticket?.cancel()
                    ticket = nil
                    switch $0 {
                    case let .failure(error):
                        promise(.failure(error))
                    case .finished:
                        break
                    }
                },
                receiveValue: {
                    ticket?.cancel()
                    ticket = nil
                    promise(.success($0))
                }
            )
        }
    }
}
