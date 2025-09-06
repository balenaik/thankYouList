//
//  AnyPublisher+Operators.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/04/18.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine

struct SubscriptionHandler<Output, Failure: Error> {
    let onNext: ((Output) -> Void)
    let onError: ((Failure) -> Void)
    let onComplete: (() -> Void)
}

extension AnyPublisher {
    static func create(_ subscribe: @escaping (SubscriptionHandler<Output, Failure>) -> Cancellable) -> Self {
        let subject = PassthroughSubject<Output, Failure>()
        var cancellable: Cancellable?
        return subject
            .handleEvents(receiveSubscription: { subscription in
                cancellable = subscribe(SubscriptionHandler(
                    onNext: { output in subject.send(output) },
                    onError: { failure in subject.send(completion: .failure(failure)) },
                    onComplete: { subject.send(completion: .finished) }
                ))
            }, receiveCancel: { cancellable?.cancel() })
            .eraseToAnyPublisher()
    }
}
